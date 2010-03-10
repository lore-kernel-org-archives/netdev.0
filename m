From: Julien Vehent <julien@linuxwall.info>
Subject: can SFQ and perturb break paquet ordering =?UTF-8?Q?=3F?=
Date: Wed, 10 Mar 2010 13:22:50 +0100
Message-ID: <ca4f1a12b3ba9c81f3276c091063613f@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:37701 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147Ab0CJMW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 07:22:59 -0500
Received: from smtp3-g21.free.fr (localhost [127.0.0.1])
	by smtp3-g21.free.fr (Postfix) with ESMTP id 9A3A3818050
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 13:22:53 +0100 (CET)
Received: from ptichoun.linuxwall.info (ver44-2-82-242-128-240.fbx.proxad.net [82.242.128.240])
	by smtp3-g21.free.fr (Postfix) with ESMTP id BBBFD818141
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 13:22:50 +0100 (CET)
Received: from ptichoun.linuxwall.info (localhost [127.0.0.1])
	by ptichoun.linuxwall.info (Postfix) with ESMTP id 6FCD2123042
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 13:22:50 +0100 (CET)
Received: from njm.linuxwall.info (localhost [127.0.0.1])
	by ptichoun.linuxwall.info (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 13:22:50 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev folks,

I was digging into the sch_sfq code and I was wondering the following (I
assume it's nothing new, I'm just trying to get it right):

Let's consider one UDP connection that has two packets. Packet#1 goes to
bucket#1, then perturb modifies the hashing algorithms and thus Packet#2
goes to bucket#800.

If the round robin was positionned after bucket#1 but before bucket#800
when perturb occured, then Packet#2 will be sent before Packet#1. And since
UDP can't reordered, it will be processed before on the received end.

Am I getting this right or is there something in the code that I missed ?


Thanks for your help.

Julien Vehent
