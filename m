From: "juice" <juice@swagman.org>
Subject: Re: Hight speed data sending from custom IP out of kernel
Date: Thu, 21 Apr 2011 23:27:30 +0300
Message-ID: <833c0a3df92bf44c2966fb54bbded876.squirrel@www.liukuma.net>
References: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>
    <4DAD76F1.40309@monstr.eu>
    <45cb2254ff23a4977c95b0f9459e39a6.squirrel@www.liukuma.net>
    <BANLkTikF5qz4pBLHsTZS1+oQxYAfQSD+cg@mail.gmail.com>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "zhou rui" <zhourui.cn@gmail.com>, monstr@monstr.eu,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:48709 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533Ab1DUU1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 16:27:37 -0400
In-Reply-To: <BANLkTikF5qz4pBLHsTZS1+oQxYAfQSD+cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> There is not a lot of documentation, and the module is still "work in
>> progress" as I am going to fix it to work with more than one interface
>> at
>> the same time when I get to do it. Currently it can only use one
>> interface
>> on the sending host machine.
>>
>
> does it use the same command/config file as pktgen?
> or special command?
>

The commands are similar type but different than pktgen.

First, when loading the module the intreface to be used must be given as
parameter, like this: "sudo insmod ./streamgen.ko interface=eth0"
Optional parameter is the UDP port that the userspace loader program uses
to communicate with the module. default port is 5555.

Then, the streamer module creates file "/proc/net/streamgen/control" which
is used to read status of module and command it:

juice@alaspin:~$ sudo cat /proc/net/streamgen/control
Stream Generator v.0.02

  State:      off
  Repeat:     1
  Queue size: 600 packets

juice@alaspin:~$

The commands that can be used are "repeat <num>", "start", "stop",
"delete" and "clear_counters"
The repeat command sets how many times the loaded sequence is output, zero
means forever. Commands run and stop work as expected. Command delete
clears the sequence from memory and command clear_counters zeroes the
packet counters.





