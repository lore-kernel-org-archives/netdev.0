From: Dragoslav Zaric <dragoslav.zaric.kd@gmail.com>
Subject: Socket Server breaks after 1000 client requests
Date: Thu, 31 Dec 2009 20:11:15 +0100
Message-ID: <2d05c4580912311111w6abaa007y5d212dd8fbde24d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:50462 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbZLaTLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 14:11:16 -0500
Received: by bwz27 with SMTP id 27so8083696bwz.21
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 11:11:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I wrote C++ Socket class. This class wraps methods both for client and server,
so you can create server or client depending what methods you call.

Anyway, all in all, problem is:

I have 3 small programs. One is server that listens in loop on port 30000.
Second is client program that sends one message to the server.
The third one on is small program (called spawn) that forks and
executes client program in limited for loop. So , idea is to simulate
a lot of connections to the server and see how many he can handle and
how.

So, at first I start server, execute spawn, and server gets client
messages. First I try 10 clients, then 100, then 1000 and it worked
Then I tried 10000 clients, and then it breaks just above 1000
clients, plus minus 100 !! So then I tried to put in server code 5
threads and mutex, but the result is same around 1000 clients and
breaks. Then I put semaphore, but then i realized that in this
scenario semaphores are of no use, because you can not sync with
random client events.

I also tried to change value in listen() method, but then I read
somewhere that maximum is 5 connections, which is default.

Does this problem requires some change in kernel code, or tcp/ip
stack, or the solution is simple, like reset server when it has first
break. I tried this last solution, but nothing happens.

So , does anyone have any idea?

Please help, I am working on this for days

thanks
