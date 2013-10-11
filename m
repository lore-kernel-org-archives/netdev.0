From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Peak TCP performance
Date: Fri, 11 Oct 2013 10:46:02 -0700
Message-ID: <5258395A.3030704@hp.com>
References: <CAJoZ4U2eVUd4JiGQ6UFYMdoEwyN=MO8+9S3jGcsaYGN2vqt=3g@mail.gmail.com> <1381461664.4971.97.camel@edumazet-glaptop.roam.corp.google.com> <CAJoZ4U0tpKhknMLd7kN4uQmq-E81=EbH1Q816nX_eig=tGreAQ@mail.gmail.com> <1381463075.4971.99.camel@edumazet-glaptop.roam.corp.google.com> <CAJoZ4U2CRaF+kvgXhbq3DNkMdYbouoKdU-xAUAkuhD5LbC7X8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kyle Hubert <khubert@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:34986 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330Ab3JKRqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 13:46:04 -0400
In-Reply-To: <CAJoZ4U2CRaF+kvgXhbq3DNkMdYbouoKdU-xAUAkuhD5LbC7X8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2013 09:21 PM, Kyle Hubert wrote:
> On Thu, Oct 10, 2013 at 11:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> Also, my copy of ethtool does not recognize tx-nocache-copy. However,
>>> I do have control over the net device. Is there something there I can
>>> set, or is tx-nocache-copy also a new feature? I'll start digging.
>>>
>>
>> nocache-copy was added in 3.0, but I do find its not a gain for current
>> cpus.
>>
>> You could get a fresh copy of ethtool sources :
>>
>> git clone git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
>> cd ethtool
>> ./autogen.sh  ...
>
> That did the trick. Thanks for the help! Is there somewhere I can read
> up on this feature? A lot of the netdev features are opaque to me.
> Also, I can set NETIF_F_NOCACHE_COPY in the netdev->features to set
> this by default, yes?
>
> This at least mirrors the performance improvement that I see when
> forwarding, however I still see reserved CPU time. Is there a way to
> push it even farther?

Thought I would point-out that unless you do concrete steps to make it 
behave otherwise, netperf will constantly present the same set of 
cache-clean buffers to the transport.  The size of those buffers will be 
determined by some heuristics and will depend on the socket buffer size 
at the time the data socket is create, which itself will depend on 
whether or not you have used a test-specific -s option.  And the 
test-specific -m option will come into play.

If I am recalling correctly, the number of buffers will be one more than:

initialSO_SNDBUF / send_size

though you can control that with global -W option.

happy benchmarking,

rick jones
