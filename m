From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.49
Date: Wed, 04 Dec 2002 00:04:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DED3869.5E47D7A2@isg.de>
References: <Pine.GSO.4.30.0211290753590.3643-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,

> Just thought of something, it may be a little tricky but valuable and
> i am not quiet sure if it should part of your patch: We probably need to
> flush the qdiscs software queues; maybe even the DMA ring i.e simulate
> admin down followed by admin up.

dev_close() is doing quite a lot of stuff, so we should do nothing more
than flush the qdiscs when the link comes up. But is it really useful?
Normally, the queues are short anyway to keep latencies low, and fifty
additional packets don't hurt. I rather think about clearing neighbor
tables and the route cache whenever the operstatus goes down.

Anyway, implementation and usage of the notification should not mix up,
so it let it be a separate patch.

Stefan
