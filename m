From: Neil Horman <nhorman@redhat.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 16:54:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4148AC06.60400@redhat.com>
References: <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com> <4148A51F.7030909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, Netdev <netdev@oss.sgi.com>,
        leonid.grossman@s2io.com, Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4148A51F.7030909@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> David Stevens wrote:
> 
>> I've never understood why people are so interested in off-loading
>> networking. Isn't that just a multi-processor system where you can't
>> use any of the network processor cycles for anything else? And, of
>> course, to be cheap, the network processor will be slower, and much
>> harder to debug and update software.
> 
> 
> Well I do agree there is a strong don't-bother-with-TOE argument: 
> Moore's law, the CPUs (manufactured in vast quantities) will usually
> 
> 
> However, there are companies are Just Gotta Do TOE...  and I am not 
> inclined to assist in any effort that compromises Linux's RFC compliancy 
> or security.  Current TOE efforts seem to be of the "shove your data 
> through this black box" variety, which is rather disheartening.
> 
> Even non-TOE NICs these days have ever-more-complex firmwares.  tg3 is a 
> MIPS-based engine for example.
> 
> 
>> If the PCI bus is too slow, or MTU's too small, wouldn't
>> it be better to fix those directly and use a fast host processor that can
>> also do other things when not needed for networking? And why have
>> memory on a NIC that can't be used by other things?
> 
> 
> PCI bus tends to be slower than DRAM<->CPU speed, and MTUs across the 
> Internet will be small as long as ethernet enjoys continued success.
> 
>     Jeff

There is also something to be said for the embedded market here. 
offload chips are fairly usefull when building switches and routers. 
Dave M. in a thread just a few weeks ago provided some metrics for how 
much bandwidth a PCI-x bus and a some-odd-gigahertz processor could 
handle.  It worked that a pc with the right componenets could 
theoretically handle about 4 gigahertz nics running traffic full duplex 
at line rate.  Thats great, but it doesn't come close to what you need 
for a 24 port gigabit L3 switch, nor does it approach the correct price 
point.  Most of these designs use a less expensive processor running at 
a slower speed, and an offload chip (that incorporates tx/rx logic and a 
switching fabric) to preform most of the routing and switching.  For 
cost concious network equipment manufacturers, they are really the way 
to go.  Unfortunately, many of them don't actaully run as a 
co-processor, and so don't enable Jeff's idea very well (yet :))

Neil

-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/
