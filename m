From: "Kingsley Foreman" <kingsley@internode.com.au>
Subject: help with cbq scheduling
Date: Thu, 22 Jan 2009 21:45:20 +1030
Message-ID: <D23A1874EC384E71A8E4B0EA5CD2FDF6@UgLyPuNk>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail04.adl2.internode.on.net ([203.16.214.57]:43879 "EHLO
	ipmail04.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179AbZAVLPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 06:15:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Im having a small problem with scheduling which I was hoping i could get 
some help with.

Im trying to setup a semi complex set of pools for a project im working on. 
Im using cbqinit however I don't understand how or if parents work the way 
im expecting them too.

What I want to do is have 3 main pools ( on a gig link)

A 400mbits max
B 400mbits max
c 300mbits max

however under "c" I want some sub pools

c.1 150mbit max
c.2 200mbit max
c.3 250mbit max

However I don't want the sub groups of "c" to ever use more then the 
300mbits it is allowed.

Ive tried using parent in cbqinit however it is ignoring the "c" pool rule 
and just using however much the sub pools c1, c2, c3 want to use. So it is 
using a max of 600mbits not 300mbits.


my cbqinit files are

cbq-1280.A
________________________________________
DEVICE=eth0,1000Mbit,100Mbit
RATE=400Mbit
WEIGHT=40Mbit
REALM=5
LEAF=none
BOUNDED=yes
_______________________________________

cbq-1281.B
________________________________________
DEVICE=eth0,1000Mbit,100Mbit
RATE=400Mbit
WEIGHT=40Mbit
RULE=xxx.xxx.xxx.xxx:80,
LEAF=none
BOUNDED=yes
_______________________________________

cbq-1282.C
________________________________________
DEVICE=eth0,1000Mbit,100Mbit
RATE=300Mbit
WEIGHT=30Mbit
LEAF=none
BOUNDED=yes
_______________________________________

cbq-1283.C1
________________________________________
DEVICE=eth0,1000Mbit,100Mbit
RATE=150Mbit
WEIGHT=15Mbit
RULE=xxx.xxx.xxx.xxx:80,
LEAF=none
PARENT=1282
BOUNDED=yes
_______________________________________

cbq-1284.C2
________________________________________
DEVICE=eth0,1000Mbit,100Mbit
RATE=200Mbit
WEIGHT=20Mbit
RULE=xxx.xxx.xxx.xxx:80,
LEAF=none
PARENT=1282
BOUNDED=yes
_______________________________________

cbq-1285.C3
________________________________________
DEVICE=eth0,1000Mbit,100Mbit
RATE=150Mbit
WEIGHT=15Mbit
RULE=xxx.xxx.xxx.xxx:80,
LEAF=none
PARENT=1282
BOUNDED=yes
_______________________________________



Any help would be great. Im stumped, or just mis-interpreting things.


Kingsley Foreman
Technical Leader Content Services / Content Services Group

=============================================
Internode Systems Pty Ltd

PO Box 284, Rundle Mall 5000
Level 5 150 Grenfell Street, Adelaide 5000
Phone:  +61 8 8228 2978
Fax:    +61 8 8235 6978
Web:    http://www.internode.on.net
        http://games.on.net
============================================= 

