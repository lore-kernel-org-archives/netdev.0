From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: dev_change_net_namespace() and synchronize_net()
Date: Tue, 27 Jan 2009 11:23:11 +0100
Message-ID: <497EE08F.5050704@dev.6wind.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:39078 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbZA0Kde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:33:34 -0500
Received: from smtp1-g21.free.fr (smtp1-g21.free.fr [212.27.42.1])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id 30EF92D588
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 11:24:29 +0100 (CET)
Received: from smtp1-g21.free.fr (localhost [127.0.0.1])
	by smtp1-g21.free.fr (Postfix) with ESMTP id 54932940099
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 11:23:14 +0100 (CET)
Received: from [192.168.1.1] (shm67-6-88-178-145-40.fbx.proxad.net [88.178.145.40])
	by smtp1-g21.free.fr (Postfix) with ESMTP id 5B6729401C0
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 11:23:12 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

I'm asking me philosophical questions about synchronize_net(). In my 
understanding, it is used to ensure that processing of current packets are finished.

In function dev_change_net_namespace(), synchronize_net() is called twice:

One time, between dev_close() and dev_shutdown(). I don't understand why it's 
needed here:
  - if interface is down, no packet can be processed by it
  - if interface is up, dev_close() will call dev_deactivate() which will call 
synchronize_rcu() (equivalent to synchronize_net()).

Second time, synchronize_net() is called just before exiting. Is it really 
necessary?


Thank you for your answers,
Nicolas
