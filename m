From: Dmitry Krivoschekov <dmitry.krivoschekov@gmail.com>
Subject: Re: [PATCH 0/3] ipconfig tweaks
Date: Fri, 17 Apr 2009 14:00:40 +0400
Message-ID: <49E85348.8080906@gmail.com>
References: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com> <20090417.012316.209396377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:7499 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757673AbZDQJ7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 05:59:22 -0400
Received: by fg-out-1718.google.com with SMTP id e12so266630fga.17
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 02:59:20 -0700 (PDT)
In-Reply-To: <20090417.012316.209396377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>From: dmitry.krivoschekov@gmail.com
>Date: Thu, 16 Apr 2009 13:37:36 +0400
>
>
>>this patch series adds some flexibility to ip_auto_config() function.
>>Currently the function assumes that 500 msec delay before opening
>>a network device is enough, but it's not true for some h/w configurations,
>>e.g. if you're using a USB network device. 
>>In my case it may take up to 2 seconds before the device gets available 
>>for opening.
>>
>
>I think this problem space would be served better by a scheme
>that just worked automatically.
>
yes, sure, and my third patch tries to add such a scheme:
http://www.spinics.net/lists/netdev/msg94723.html

while the first two patches can be considered separately:
http://www.spinics.net/lists/netdev/msg94724.html
http://www.spinics.net/lists/netdev/msg94726.html

as the patches allow you to change that pre-defined delays, i.e. you
can adjust the delays for your particular system. As I wrote it could
save about 1 second of boot-up time.

>
>If the user put nfsroot= onto the kernel command line, the expectation
>is that the device is expected to be there.
>
>
Agreed.

>Therefore it is reasonable to make the ipconfig.c code do a loop
>periodically retrying to open the intended network device.  And after
>several seconds of iterations, fail.
>

Why it should fail? What do you expect from the system to do when it fails?
It gets unusable anyways and you'll have to reboot it again. But, if it will
be infinitely looping, there is a chance it finds something suitable :).
If you're sure it won't find anything then reboot it and configure it 
properly.
In fact, DHCP code can loop infinitely (see "try_try_again" loop).

>
>Heck, it doesn't even need to do anything fancy.  After the initial
>attempt, it can simply wait for the NETDEV_REGISTER notifier event.
>Then it will know exactly when the device shows up.
>
>In fact you won't need anything to implement this, simply register the
>notifier and make the notifier trigger the ipconfig.c code to do a
>DHCP or RARP probe or whatever when the device we're interested in
>appears.
>
>
ok, I'try it

>I'm not applying these patches, sorry.
>

As I wrote above, the first two patches can be considered separately.
Why don't let users to optimize boot-up time?


Thanks,
Dmitry

