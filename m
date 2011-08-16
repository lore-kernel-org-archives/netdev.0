From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: Linux ipsec and dynamic routing
Date: Tue, 16 Aug 2011 07:51:45 -0400
Message-ID: <4E4A59D1.1070005@earthlink.net>
References: <2B8C0848-C5A1-4F19-AFDF-C7CB443789E0@kuiki.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hachi <hachi@kuiki.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:52296 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752025Ab1HPLvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 07:51:48 -0400
In-Reply-To: <2B8C0848-C5A1-4F19-AFDF-C7CB443789E0@kuiki.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2011 04:58 AM, hachi wrote:
> Hello heroes!
>
> I am after an eventual goal of dynamic routing (BGP) via the linux kernel using ipsec tunneling and no inner tunnel (gre or others). On the way to this goal I've done some light source diving of source and talked a little theory with others to hunt down as much as I could to get closer. I have a lot of questions here, so thanks for any answers or suggestions you may give.
>
> All of my testing is done using openswan, and debian stable (linux 2.6.32, iproute 20100519)
>
> * Are there any existing methods of implementing dynamic routed ipsec armored ip forwarding?
>
> I haven't been able to find anyone who has a working setup in this regard. My goal is very similar to the exposed routing setup of Amazon's VPC ipsec connections. I'm trying to implement one or both ends in linux successfully and haven't found any docs on the subject.
>
> * The ip xfrm policy selector syntax has a 'dev' argument that can be supplied. I was unable to figure out what the intention of this argument is via source, and I never found any docs or samples of its use. Can anyone enlighten me?
>
> * Are there any plans or generally accepted patches to expand the rules that may be used to select what frames are transformed?
>
> Currently the rules I can use are source address, destination address, and the mysterious 'dev' setting. I think the ultimate solution for me would be able to select frames for forwarding based on the gateway defined in the normal routing tables.
>
> * Do ip xfrm policy rules bypass normal routing policy?
>
> I'm relatively certain the answer to this is 'yes'. However I may not have the full story.
>
> I ran a simple test of two /24 exposed at either end of an ipsec tunnel. The left end is 10.24.2.0/24, the right is 10.24.3.0/24, and the transit is being done via 10.24.1.0/30. I configured this test using openswan and after setting up and checking to see if the boxes can pass frames I examined the policy list and the routing table.
>
> src 10.24.3.0/24 dst 10.24.2.0/24
> 	dir fwd priority 2344 ptype main
> 	tmpl src 10.24.1.2 dst 10.24.1.1
> 		proto esp reqid 16385 mode tunnel
>
> 10.24.1.0/30 dev eth1  proto kernel  scope link  src 10.24.1.1
> 10.24.2.0/24 dev eth0  proto kernel  scope link  src 10.24.2.2
> 172.16.3.0/24 dev eth0  proto kernel  scope link  src 172.16.3.16
> default via 172.16.3.1 dev eth0
>
> The opposite end is appropriately reversed, and there are two more policies for 'in' and 'out', but they are appropriately similar.
>
> What I notice is that despite not having a route for the exposed subnet on the other end of the tunnel linux happily forwards the frames and encodes them to the other end, and visa versa.
>
> I can watch the frames passing across eth1 and they are appropriately encrypted as specified, and if I turn the ipsec tunnel off on both sides the forwarding capability does indeed shut down. If I add routes for the opposing ends then the kernel starts forwarding frames as expected.
>
> * If I need to dive into this more to seek an implementation, does anyone know if the general theory should be the dynamic routing daemon in userspace should expand its code to update xfrm policies, or is the fact that xfrm policy is taking precedence over routing an oversight of the kernel code that should be fixed/updated/etc. ?
>
> * Is there any hope for policy routing table support to extend into this as well?
>
> I hope I'm reaching out to the proper group for this inquiry, please let me know if this was wrong :)
>
> --hachi--
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>    
Did you get any responses? I would certainly like to know the answers to 
some of the questions you posed.

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



