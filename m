From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Fri, 15 Feb 2013 21:25:24 -0500
Message-ID: <511EEE14.8050902@redhat.com>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>   <511E8760.9070703@candelatech.com>  <1360955900.19353.22.camel@edumazet-glaptop>  <511E8C3D.5070603@candelatech.com> <1360956930.19353.24.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	kaber@trash.net, ataschner@suse.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416Ab3BPCZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 21:25:35 -0500
In-Reply-To: <1360956930.19353.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2013 02:35 PM, Eric Dumazet wrote:
> On Fri, 2013-02-15 at 11:27 -0800, Ben Greear wrote:
>
>> For some reason I was thinking this wasn't fully fixed for IPv4, but
>> maybe it is..the bug in our internal tracker only mentions IPv6
>> as having issues...
>>
>> We'll do some testing on IPv4 sometime soon to make sure, and can test
>> IPv6 patches as well...
>
> This worries me a bit, as I wrote this patch because you reported the
> issue.
>
> commit bc416d9768aa9a2e46eb11354a9c58399dafeb01
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Thu Oct 6 10:28:31 2011 +0000
>
>      macvlan: handle fragmented multicast frames
>
>      Fragmented multicast frames are delivered to a single macvlan port,
>      because ip defrag logic considers other samples are redundant.
>
>      Implement a defrag step before trying to send the multicast frame.
>
>      Reported-by: Ben Greear <greearb@candelatech.com>
>      Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>      Signed-off-by: David S. Miller <davem@davemloft.net>
>
>

Yep, IPv4 is there.  IPv6 is not and is a lot harder/more interesting 
since IPv6 may be disable, but reassembly may still need to work to
service the taps connected to VMs.  :(

The only reason I say this is because I've ran into too many people who
turn IPv6 off for "security reasons".

-vlad

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
