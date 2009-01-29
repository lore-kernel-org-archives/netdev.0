From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: iproute2, meta, flex parser bug?
Date: Thu, 29 Jan 2009 13:04:24 +0200
Message-ID: <200901291304.24257.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:49177 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbZA2LEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 06:04:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to make meta work, without success. Seems parser done in flex 
failing. My knowledge is not enough to fix or understand how flex is working
Here is what i got:

home iproute2 # home iproute2 # tc/tc filter add dev eth0 protocol ip pref 11 
basic match meta\(rt_iif eq \"eth0\"\)
meta: unknown meta id

... meta(rt_iif >>eq<< ...
... meta(rt_iif eq >>"eth0"<<)...
Usage: meta(OBJECT { eq | lt | gt } OBJECT)
where: OBJECT  := { META_ID | VALUE }
       META_ID := id [ shift SHIFT ] [ mask MASK ]

Example: meta(nfmark gt 24)
         meta(indev shift 1 eq "ppp")
         meta(tcindex mask 0xf0 eq 0xf0)

For a list of meta identifiers, use meta(list).
Illegal "ematch"

I try with debug, and how flex is working - strange for me
--(end of buffer or a NUL)
--accepting rule at line 139 ("meta")
--accepting rule at line 135 ("(")
--accepting rule at line 139 ("rt_iif")
--(end of buffer or a NUL)
--accepting rule at line 70 (" ")
--accepting rule at line 139 ("eq")
--(end of buffer or a NUL)
--accepting rule at line 70 (" ")
--accepting rule at line 139 (""eth0"")
--accepting rule at line 136 (")")
--(end of buffer or a NUL)
--accepting rule at line 70 (" ")
--(end of buffer or a NUL)
--EOF (start condition 0)

Even with numbers
tc/tc filter add dev eth0 protocol ip pref 11 basic match meta\(rt_iif eq 
123\)
--(end of buffer or a NUL)
--accepting rule at line 139 ("meta")
--accepting rule at line 135 ("(")
--accepting rule at line 139 ("rt_iif")
--(end of buffer or a NUL)
--accepting rule at line 70 (" ")
--accepting rule at line 139 ("eq")
--(end of buffer or a NUL)
--accepting rule at line 70 (" ")
--accepting rule at line 139 ("123")
--accepting rule at line 136 (")")
--(end of buffer or a NUL)
--accepting rule at line 70 (" ")
--(end of buffer or a NUL)
--EOF (start condition 0)

It seems it is not matching any rules except 

70 [ \t\r\n]+
136 ")"                                   
139 [^ \t\r\n()]+                        

In flex rules all looks correct, but maybe i miss something.
My software versions
bison (GNU Bison) 2.3
flex 2.5.35
gcc version 4.3.2 (Gentoo 4.3.2 p1.2)
iproute2 is latest git
