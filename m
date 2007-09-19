From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Wed, 19 Sep 2007 10:53:01 -0400
Message-ID: <780b6f780709190753qd52d099id937a6c75e5d560e@mail.gmail.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	 <36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	 <20070918020358.d50653d5.billfink@mindspring.com>
	 <ygfps0g8lj0.fsf@janus.isnogud.escape.de> <82k5qoxfbk.fsf@mid.bfk.de>
	 <780b6f780709180932j5944b927p44ace42833e0230b@mail.gmail.com>
	 <08FE5CC30C9A3F41BF819A502CF7BF6E02045257@fmsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Florian Weimer" <fweimer@bfk.de>,
	"Urs Thuermann" <urs@isnogud.escape.de>,
	"Bill Fink" <billfink@mindspring.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, netdev@vger.kernel.org
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:54184 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbXISOxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 10:53:02 -0400
Received: by wa-out-1112.google.com with SMTP id v27so256535wah
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 07:53:01 -0700 (PDT)
In-Reply-To: <08FE5CC30C9A3F41BF819A502CF7BF6E02045257@fmsmsx411.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Well,
the issue seems to have gone away as of this morning, but I am
somewhat unsure as to why.
Placement of some things were modified so as to allow shorter cables.
Now there are 3' CAT6 cables everywhere except for the 15' cable
between the two switches. All the cables are new, high quality
'tested' cables from a company nearby.
The server is now running 2.6.22.6 with the 7.6.5 e1000 driver from
intel.com and samba 3.0.26-1 ... and it seems to work. Samba will not
disconnect, even with all 8 clients running unreasonable read/write
loads and CRC and MD5 checksums of the transferred files all match.
The issue therefore seems to have gone away, but the reason why still
escapes me. I cannot believe that CAT5 cables under 10' in length were
causing it, because if that were the case
1) it would've shown itself, I presume, from the beginning
2) I could name dozens of different locations which would be having
the same problems
Samba 3.0.25 was definitely part of the problem and I sent a nice
nastygram to the debian maintainers, because -testing is not
-unstable, last I checked.
As to samba having any sort of data integrity capability, to the best
of my knowledge that has never been the case.
To answer further questions: I checked for file integrity with
CRC/CRC32/MD5 checksum utilities. They used to fail fairly
consistently, they have been fine all this morning.
Here is my samba config, for reference, comments etc. stripped.

[global]
   workgroup = WORKGROUP
   server string = %h server
   wins support = yes
   dns proxy = yes
   name resolve order = host wins bcast
   log level = 1
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d
   encrypt passwords = true
   passdb backend = tdbsam
   obey pam restrictions = yes
   invalid users = root
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\sUNIX\spassword:* %n\n
*Retype\snew\sUNIX\spassword:* %n\n .
   socket options = TCP_NODELAY IPTOS_LOWDELAY
   domain master = yes
[backups]
   comment = Backup Share
   path = /var/archive/backups
   browseable = yes
   writeable = no
   guest ok = no
   write list = samba
   force user = samba
[downloads]
   comment = Downloads Share
   path = /var/archive/downloads
   browseable = yes
   writeable = no
   guest ok = no
   read list = samba
   write list = samba
   force user = samba

There is nothing there that I would deem unusual. Since the transition
to 2.6 kernels I have been omitting the buffer statements in the
socket options.
I have one further question: what should I be doing with the TSO and
flow control? As of now, TSO is on but flow control is off.
I'd like to thank everyone who helped and I'll be trying to see if the
realtek integrated NIC works next.

Luigi Fabio
