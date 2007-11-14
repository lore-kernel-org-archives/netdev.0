From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Wed, 14 Nov 2007 15:30:54 -0800
Message-ID: <473B852E.5010000@intel.com>
References: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au>
	<20071113.033611.73195922.davem@davemloft.net>
	<20071113120328.GB1086@gondor.apana.org.au>
	<20071113.040624.43544149.davem@davemloft.net>
	<20071113121647.GA1330@gondor.apana.org.au>
	<4739961E.90708@trash.net> <4739D3A5.4020503@intel.com>
	<4739DE29.2030507@trash.net> <4739DF29.6010901@intel.com>
	<473AC2EC.4060109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com,
	David Miller <davem@davemloft.net>, cfriesen@nortel.com, w@1wt.eu
To: Patrick McHardy <kaber@trash.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <473AC2EC.4060109@trash.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Kok, Auke wrote:
>> Patrick McHardy wrote:
>>> Kok, Auke wrote:
>>>> Patrick McHardy wrote:
>>>>
>>>>> I already posted a patch for this, not sure what happened to it.
>>>>> Auke, any news on merging the secondary unicast address support?
>>>> I dropped the ball on that one. Care to resend it and send me one for
>>>> e1000e as well?
>>> Patch for e1000 attached.
>>>
>>> Does e1000e also work with PCI cards if I add the proper IDs?
>>> Otherwise I could only send an untested patch.
>>>
>>
>> no, e1000e will only work with pci-e adapters. The code however is
>> largely the
>> same, so if you can dish me out (off-list) some test cases I can have
>> our labs do
>> the testing and add this to our test repertoire.
> 
> 
> Actually that part of the code is quite different. I'm not
> sure I understand the entire intent behind the differences,
> why does it use a packed array of addresses instead of simply
> passing the netdev pointer to the callback? That would be
> necessary for secondary unicast support since we have to
> disable unicast filtering if either the address count exceeds
> the number of filter slots or the device is in promiscous mode.

the underlying code was not specifically developed with linux only in mind and is
therefore not aware of the net_device struct, hence the specific netdev agnostic
implementation. if this implementation is posing issues then we need to look at
how to improve it or just code it specifically for linux in a better way.


Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
