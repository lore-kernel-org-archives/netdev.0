From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: Strange errors from e1000 driver (2.6.18)
Date: Sun, 22 Oct 2006 13:21:40 -0700
Message-ID: <4807377b0610221321i62455faende025f88142dd087@mail.gmail.com>
References: <453BBC9E.4040300@google.com> <453BC0E7.1060308@mbligh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Martin J. Bligh" <mbligh@google.com>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:29985 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751397AbWJVUVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 16:21:42 -0400
Received: by ug-out-1314.google.com with SMTP id o38so1100875ugd
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2006 13:21:40 -0700 (PDT)
To: "Martin J. Bligh" <mbligh@mbligh.org>
In-Reply-To: <453BC0E7.1060308@mbligh.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/06, Martin J. Bligh <mbligh@mbligh.org> wrote:
> Martin J. Bligh wrote:
> > I'm getting a lot of these type of errors if I run 2.6.18. If
> > I run the standard Ubuntu Dapper kernel, I don't get them.
> > What do they indicate?

Hi Martin, they indicate that you're getting transmit hangs.  Means
your hardware is having issues with some of the buffers it is being
handed.  Because the TDH and TDT noted below are not equal, it means
the hardware is hung processing buffers that the driver gave to it.

We need the standard bug report particulars, lspci -vv, cat
/proc/interrupts, dmesg, ethtool -e eth0, and maybe output of
dmidecode, etc.  I'm pretty sure you know the drill.

> > Oct 21 18:48:28 localhost kernel: buffer_info[next_to_clean]
> > Oct 21 18:48:28 localhost kernel:   time_stamp           <7b79d33>
> > Oct 21 18:48:28 localhost kernel:   next_to_watch        <3d>
> > Oct 21 18:48:28 localhost kernel:   jiffies              <7b7a0c1>
> > Oct 21 18:48:28 localhost kernel:   next_to_watch.status <0>
> > Oct 21 18:48:30 localhost kernel:   Tx Queue             <0>
> > Oct 21 18:48:30 localhost kernel:   TDH                  <3d>
> > Oct 21 18:48:30 localhost kernel:   TDT                  <44>
> > Oct 21 18:48:30 localhost kernel:   next_to_use          <44>
> > Oct 21 18:48:30 localhost kernel:   next_to_clean        <39>
<snip>

> Actually, maybe this set is more helpful:
>
> e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
>    Tx Queue             <0>
>    TDH                  <6>
>    TDT                  <1f>
>    next_to_use          <1f>
>    next_to_clean        <2>
> buffer_info[next_to_clean]
>    time_stamp           <2de8b54>
>    next_to_watch        <6>
>    jiffies              <2de8db7>
>    next_to_watch.status <0>
<snip>
> NETDEV WATCHDOG: eth0: transmit timed out
> e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex

only a little.  There are so many different pieces of e1000 hardware
and so few specifics in this report that I'll be able to tell you lots
more when you get us the info requested.

Jesse
