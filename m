From: Ben Greear <greearb@candelatech.com>
Subject: Re: Socket Server breaks after 1000 client requests
Date: Thu, 31 Dec 2009 11:22:20 -0800
Message-ID: <4B3CF9EC.9070103@candelatech.com>
References: <2d05c4580912311111w6abaa007y5d212dd8fbde24d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dragoslav Zaric <dragoslav.zaric.kd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53611 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbZLaTWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 14:22:23 -0500
In-Reply-To: <2d05c4580912311111w6abaa007y5d212dd8fbde24d9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/2009 11:11 AM, Dragoslav Zaric wrote:
> Hi,
>
> I wrote C++ Socket class. This class wraps methods both for client and server,
> so you can create server or client depending what methods you call.
>
> Anyway, all in all, problem is:

This is likely some bug with your code..as I have code that easily handles
10k connections.

> I have 3 small programs. One is server that listens in loop on port 30000.
> Second is client program that sends one message to the server.
> The third one on is small program (called spawn) that forks and
> executes client program in limited for loop. So , idea is to simulate
> a lot of connections to the server and see how many he can handle and
> how.

Use non-blocking IO and poll() instead of forking for each client.  10k processes
are going to take almost any machine to it's knees.

>
> So, at first I start server, execute spawn, and server gets client
> messages. First I try 10 clients, then 100, then 1000 and it worked
> Then I tried 10000 clients, and then it breaks just above 1000
> clients, plus minus 100 !! So then I tried to put in server code 5
> threads and mutex, but the result is same around 1000 clients and
> breaks. Then I put semaphore, but then i realized that in this
> scenario semaphores are of no use, because you can not sync with
> random client events.
>
> I also tried to change value in listen() method, but then I read
> somewhere that maximum is 5 connections, which is default.

No, you can easily make this bigger, and default is 128 for somaxconn

	echo -n "Increase somaxcon to 10000......................................... "
	echo 10000 > /proc/sys/net/core/somaxconn
	echo "DONE"

You should also let us know what you mean by 'it breaks'.  What exactly breaks?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
