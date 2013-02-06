From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V1 00/10] Mellanox Ethernet driver updates 2013-01-30
Date: Wed, 6 Feb 2013 18:58:12 +0200
Message-ID: <51128BA4.1010802@mellanox.com>
References: <1359623231-4491-1-git-send-email-amirv@mellanox.com>   <20130131.135158.206758800827480029.davem@davemloft.net>  <1360094899.2857.30.camel@bwh-desktop.uk.solarflarecom.com>  <51120547.7090608@mellanox.com> <1360165618.2659.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:47921 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754627Ab3BFQ6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 11:58:20 -0500
In-Reply-To: <1360165618.2659.5.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2013 17:46, Ben Hutchings wrote:
> On Wed, 2013-02-06 at 09:24 +0200, Amir Vadai wrote:
>> On 05/02/2013 22:08, Ben Hutchings wrote:
>>> On Thu, 2013-01-31 at 13:51 -0500, David Miller wrote:
>>>> From: Amir Vadai <amirv@mellanox.com>
>>>> Date: Thu, 31 Jan 2013 11:07:01 +0200
>>>>
>>>>> Hi Dave,
>>>>>
>>>>> This series contains updates to mlx4 driver.
>>>>> Majority of the patches are small bug fixes. Another patch is to expose through
>>>>> debugfs some HW resources to be used by external tools.
>>>>>
>>>>> Patches done against net-next commit 1b13c97: "net/vxlan: Add ethtool drvinfo"
>>>>>
>>>>> Changes from V0:
>>>>> - Removed patch "net/mlx4_en: Add debugfs support". Need to find a standard way
>>>>>    to do it, and no need to delay the other patches.
>>>>
>>>> All applied, thanks.
>>>
>>> The first time this series was posted (this is actually v2) I raised an
>>> issue with the changes to interpretation of the VLAN tag in ethtool RX
>>> NFC commands: <http://article.gmane.org/gmane.linux.network/257392/>.
>>> The semantics are now definitely inconsistent between sfc and mlx4_en.
>>> I asked Alexander what ixgbe (first implementation) does with the upper
>>> 4 bits, with the aim that all three implementations should be
>>> consistent, but I haven't had an answer to that yet.
>>>
>>> Ben.
>>>
>>
>> I'm not sure I understand the problem here.
>>
>> mlx4_en implementation is exactly like what you describe and what 
>> ethtool documentation is describing.
>>
>> We handle vlan_tci as the whole VLAN tag. Since we're only interested in 
>> the VID in our flow steering, we check that the mask sets only the 12 
>> bits of VID and use it.
>>
>>  From looking at sfc driver - it is exactly same there.
>>
>> Did I miss something?
> 
> sfc verifies that the mask (cmd->fs.m_ext.vlan_tci) is either 0 or 0xfff
> (big-endian).  If any of the top 4 bits are set we reject the flow spec
> as unsupported.  If I read correctly, mlx4_en was also doing that
> initially, but 'net/mlx4_en: Fix vlan mask for ethtool steering rules'
> changed it to ignore the top 4 bits of the mask.
> 
> Ben.
> 

Ok - now I see.

This patch should be reverted - mlx4_en should also reject setting of
the top 4 bits in the mask.

I will send a fix soon.

Thanks,
Amir
