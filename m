From: Jesse Gross <jesse@nicira.com>
Subject: Re: [regression] 2.6.37+ commit 0363466866d9.... breaks tcp ipv6
Date: Tue, 18 Jan 2011 12:06:53 -0800
Message-ID: <AANLkTinejKw0pY5HncB2e0ocjqYuCwTBUwd2xkroWu+E@mail.gmail.com>
References: <4D335417.80704@xmsnet.nl>
	<4D35EF64.1040906@xmsnet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D35EF64.1040906@xmsnet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2011 at 11:52 AM, Hans de Bruin <jmdebruin@xmsnet.nl> w=
rote:
> On 01/16/2011 09:24 PM, Hans de Bruin wrote:
>>
>> After last nights compile i lost the possibility to connect to ssh a=
nd
>> http over ipv6. The connection stops at syn_sent. connections to my
>> machine end in syn_recv. ping6 still works.
>>
>
> The bisect ended in:
>
> 0363466866d901fbc658f4e63dd61e7cc93dd0af is the first bad commit
> commit 0363466866d901fbc658f4e63dd61e7cc93dd0af
> Author: Jesse Gross <jesse@nicira.com>
> Date: =A0 Sun Jan 9 06:23:35 2011 +0000
>
> =A0 =A0net offloading: Convert checksums to use centrally computed fe=
atures.
>
> =A0 =A0In order to compute the features for other offloads (primarily
> =A0 =A0scatter/gather), we need to first check the ability of the NIC=
 to
> =A0 =A0offload the checksum for the packet. =A0Since we have already =
computed
> =A0 =A0this, we can directly use the result instead of figuring it ou=
t
> =A0 =A0again.
>
> =A0 =A0Signed-off-by: Jesse Gross <jesse@nicira.com>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
> ssh ::1 =A0still works. And since dns still works I guess udp is not =
affected.
> My nic is a:
>
> 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5752 G=
igabit
> Ethernet PCI Express (rev 02)

Are you using vlans?  If so, can you please test this patch?
http://patchwork.ozlabs.org/patch/79264/
