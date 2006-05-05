From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC] Proposed structure for Regulatory/Geographical Wireless database
Date: Fri, 05 May 2006 15:14:35 -0500
Message-ID: <445BB22B.30505@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:22465 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751706AbWEEUOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 16:14:47 -0400
To: netdev@vger.kernel.org, Faidon Liambotis <faidon@cube.gr>,
	Rick Jones <rick.jones2@hp.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Harald Welte <laforge@gnumonks.org>,
	Jouni Malinen <jkm@devicescape.com>,
	Christoph Hellwig <hch@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks to all that responded to my earlier RFC. A number of changes in my thinking are based on 
those comments, which came from Christoph Hellwig, Rick Jones, Ulrich Kunitz, Faidon Liambotis, 
Jouni Malinen,  and Harald Welte.  The important points of my proposal are as follows:

* The database will be maintained as a text file to be processed by a userland daemon that will 
transform this database into the data structure needed by the ieee80211 code. In addition to the 
regulatory data, this file will also contain the information needed for the daemon to set the size 
of its data arrays dynamically.

* A new routine (ieee80211_init_geo ?) will be written to be called by the driver to load the geo 
structure into the kernel. Information passed to the daemon will be the country code in ASCII and 
whether the interface is to be used indoors or outdoors.

* Checksum routines will be used to validate the data base. Such a simple scheme will not inhibit 
anyone with moderate skills from hacking the channel/power settings, but such hacking will require 
some effort.

* Each channel in the resulting kernel data structure will have appropriate flags set indicating if 
it is to be used indoors, outdoors, or both. In addition, if the channel should be used only for 
passive scanning, a suitable flag will be set. In the 2.4 GHz band, a flag will indicate if it 
should be used for 802.11b, otherwise both b and g mode will be assumed. In the 5.0 GHz bands, a 
flag will be set if the channel is to conform with 802.11h or 802.11a standards.

The database consists of two sections. The first relates the Country Codes to a wireless group. The 
second section describes the channel parameters for the groups. Shown below is a fragment showing 
the Country Code - Group info for a few countries and the definitions for a few of the groups.

Please send me any comments, etc.

Larry

===================================================================
# text file for IEEE80211 Regulatory/Geographical information
#
# Version of 04 May 2006
#
# Information for dynamic array sizing
#
Number of Countries: 100
Number of Groups: 15
#
# Countries listed first
#
# group Country Code    Description
#
1       AT              Austria (Standard EU)
1       DE              Germany (Standard EU)
2       FRI             France Indoor (Not Guyana or La Reunion)
3       FRO             France Outdoor (Not Guyana or La Reunion)
4       FR1             French Departments of Guyana and La Reunion Indoor
5       FR2             French Departments of Guyana and La Reunion Outdoor
.
.
.
9       US              United States (FCC)
#
#
# Groups follow countries
#
Group 0         - Unspecified Country
#
# Band  Ch. Range       Ch. Spacing     Power   Flags
#
# Band - b, bg, a, or h
# Ch. Range - Minimum and Maximum Channels for this range
# Ch. Spacing - Number of channels between adjacent entries
# Power in mW EIRP
# Flag Codes
# B - Both Indoor and Outdoor
# I - Indoor Only
# O - Outdoor Only
# P - Passive Scan Only
#
bg        1 - 11        1                100    B
#
Group 1         - General European Union (EU)
#
bg        1 -  13       1                100    B
h        36 -  40       4                200    I
h        52 -  64       4                200    IP
h       100 - 140       4               1000    BP
#
Group 2         - France Indoor (Not Guyana or La Reunion)
#
bg        1 -  13       1                100    I
h        36 -  48       4                200    I
h        52 -  64       4                200    IP
h       100 - 140       4               1000    IP
#
Group 3         - France Outdoor (Not Guyana or La Reunion)
#
bg        1 -   8       1                100    O
bg        9 -  13       1                 10    O
h       100 - 140       4               1000    OP
.
.
.
.
#
Group 9         - US (FCC)
#
bg        1 -  11       1                100    B
a        36 -  40       4                200    I
a        52 -  64       4                200    B
a       149 - 161       4               1000    B
#
