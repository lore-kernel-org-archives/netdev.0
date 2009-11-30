From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: net 00/05: routing based send-to-self implementation
Date: Mon, 30 Nov 2009 12:15:41 -0800
Message-ID: <4B1427ED.6070808@candelatech.com>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <m1r5rf4xm9.fsf@fess.ebiederm.org> <4B141EFB.4070409@candelatech.com> <20091130200430.GS14610@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46801 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbZK3UPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:15:39 -0500
In-Reply-To: <20091130200430.GS14610@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2009 12:04 PM, Benjamin LaHaise wrote:
> On Mon, Nov 30, 2009 at 11:37:31AM -0800, Ben Greear wrote:
>> This doesn't work if you want to have one application manage lots of
>> interfaces and send traffic between these interfaces.  Certainly there are
>> use-cases that can use multiple name-spaces, but it's nice to have the
>> option not to use them as well.
>
> Actually, it's quite doable from within one application.  An application
> I recently adapted to make use of multiple network namespaces within a single
> process by way of pthreads and unshare(CLONE_NEWNET).  The scheme I used
> is to just open the socket in a new namespace in a thread.  Since the
> file descriptor table is still shared, it's easy to send/receive data from
> any other thread, regardless of which virtual network namespace it's in.
> All told, setting up virtual routers with namespaces is pretty easy.

That still sounds more complicated than the proposed routing table changes,
at least for my application.  Since I also want to gather stats, set/watch routes,
etc, on each network device, would I have to keep a thread and netlink socket
running in each name-space in order to see the various devices?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

