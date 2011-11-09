From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: ip_local_deliver_finish: proto 108 (IPComp) isn't netns-ready
Date: Wed, 09 Nov 2011 14:38:16 -0800
Message-ID: <m1d3d0oraf.fsf@fess.ebiederm.org>
References: <1320858706.2531.45.camel@pro6455b.example.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jmorris@namei.org,
	<netdev@vger.kernel.org>, adobrian@gmail.com
To: dilip.daya@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320858706.2531.45.camel@pro6455b.example.com> (Dilip Daya's
	message of "Wed, 09 Nov 2011 12:11:46 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dilip Daya <dilip.daya@hp.com> writes:

> Hi All,
>
> LTP-network tests produced:
>
> 	"ip_local_deliver_finish: proto 108 (IPComp) isn't netns-ready"
>
> Question:
> Is the above a bug or feature (IPComp, mode: transport) not netns
> enabled?

I would call it a missing feature.

> Environment:
>
> * v3.1-stable kernel.
>
> * Configured two network-namespaces via "ip netns add ...".
>   on a single system: netns0 (assigned as server) and
>   netns1 (assigned as client).
>   - assigned multiple physical NICs to netns0 and netns1.
>
> * Entered netns1 (ip netns exec netns1 bash) to execute
>   ltp-network suite of tests between netns1 and netns0.
>
> * The following LTP tests produced messages:
>
>   "kernel: ip_local_deliver_finish: proto 108 isn't netns-ready"
>
>    - /usr/lib/ltp/testcases/bin/icmp4-multi-diffip06
>    - /usr/lib/ltp/testcases/bin/tcp4-multi-diffip13
>    - /usr/lib/ltp/testcases/bin/udp4-multi-diffip06
>    - /usr/lib/ltp/testcases/bin/udp4-multi-diffnic06
>    - /usr/lib/ltp/testcases/bin/udp4-multi-diffport06
>
> * I also noticed missing ".netns_ok = 1" in:
>   - http://lxr.linux.no/linux+v3.1/net/ipv4/ipcomp.c#L150

The .netns_ok flag indicates that someone has audited the code and made
certain it all works with network namespaces.

Skimming the code I don't see anything that jumps out as me as
wrong.  And it looks like Alexy did the work in Jan of 2010.

   commit a92df2545402c1a08e7a158f4477a52dea0eeeed
   Author: Alexey Dobriyan <adobriyan@gmail.com>
   Date:   Mon Jan 25 10:38:34 2010 +0000
   
       netns xfrm: ipcomp support
       
       Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
       Signed-off-by: David S. Miller <davem@davemloft.net>

However it is clear that no one has actually tested ipcomp with
network namespaces.

If you have a clue what is going on with ip compression my
recommendation would be to add .netns_ok = 1.  Verify that the
everything works and send the patch.  You probably want to
verify and test ipv6 as well.  It really looks like the code
is fine and it just needs to be enabled.

Eric
