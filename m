From: jamal <hadi@cyberus.ca>
Subject: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Sun, 27 May 2007 09:34:27 -0400
Message-ID: <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	"Zhang Rui" <rui.zhang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.227]:32023 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbXE0Ne2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 09:34:28 -0400
Received: by nz-out-0506.google.com with SMTP id n1so669737nzf
        for <netdev@vger.kernel.org>; Sun, 27 May 2007 06:34:27 -0700 (PDT)
In-Reply-To: <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I can never get these web-browser email clients to work well.
Sorry for sending fscking html earlier.

cheers,
jamal

---------- Forwarded message ----------
From: jamal <hadi@cyberus.ca>
Date: May 27, 2007 9:29 AM
Subject: Re: [PATCH] [-mm] ACPI: export ACPI events via netlink
To: Zhang Rui <rui.zhang@intel.com>
Cc: linux-acpi@vger.kernel.org, netdev@vger.kernel.org




On 5/27/07, Zhang Rui <rui.zhang@intel.com> wrote:
>
> I need to write a user application to test my patch.
> Netlink messages can be sent/received using the standard socket API.

sure.

> But how to receive Genetlink messages from specified genetlink family?
> There is no socket ACPI with such a parameter, right?

Each module has a unique identifier that it receives dynamically on
 insertion at the kernel.

> Do I have to receive all the genetlink messages first?

 No, just the ones for your dynamic id. Try what i described first for
 kernel side on the earlier email. I will repeat it here for clarity.
Then look at genl code and if you have questions i can
 help.
Note: You need to discover your dynamic id (the iproute2/genl code has a stub
example code)
 As i told you in the earlier email, in your development:
 - start first by just writting your kernel side.
 - Then use the genl utility - which is part of iproute2 to see if the
 kernel side is "discoverable".

 E.g if i wanted to "discover" currently loaded modules on my laptop, i
 would do this:

 ---------------
 hadi@lilsol:~$ genl ctrl ls

 Name: nlctrl
         ID: 0x10  Version: 0x2  header size: 0  max attribs: 6
         commands supported:
                 #1:  ID-0x3  flags-0xe


 Name: nl80211
         ID: 0x11  Version: 0x1  header size: 0  max attribs: 22
         commands supported:
                 #1:  ID-0x1  flags-0xa
                 #2:  ID-0x6  flags-0xa
                 #3:  ID-0x8  flags-0xa
                 #4:  ID-0x3  flags-0xb
                 #5:  ID-0x4  flags-0xb
                 #6:  ID-0x5  flags-0xb
                 #7:  ID-0xa  flags-0xb
                 #8:  ID-0xb  flags-0xa
                 #9:  ID-0xf  flags-0xb
                 #10:  ID-0x10  flags-0xa
                 #11:  ID-0x12  flags-0xb
                 #12:  ID-0x13  flags-0xa
                 #13:  ID-0x15  flags-0xa
                 #14:  ID-0x19  flags-0xb
                 #15:  ID-0x17  flags-0xb
                 #16:  ID-0x18  flags-0xb
                 #17:  ID-0x1a  flags-0xb
                 #18:  ID-0x1b  flags-0xa
                 #19:  ID-0xd  flags-0xb


 Name: TASKSTATS
         ID: 0x12  Version: 0x1  header size: 0  max attribs: 4
         commands supported:
                 #1:  ID-0x1  flags-0xa
 ---------------------------

 As you can see, i can see from user space the name of the kernel end
 point, its numeric id, what version it is running (so i can make sure
 user space is compatible), what extra header it may have, what the
 maximum number of attributes it can take. The last thing that gets
 listed is the commands, and flags for those commands.

 Lets load tipc kernel module and repeat...

 -----------

 hadi@lilsol:~$ sudo modprobe tipc
 Name: nlctrl
         ID: 0x10  Version: 0x2  header size: 0  max attribs: 6
         commands supported:
                 #1:  ID-0x3  flags-0xe

 ....
 [same as before]
 ....

 Name: TIPC
         ID: 0x13  Version: 0x1  header size: 8  max attribs: 0
         commands supported:
                 #1:  ID-0x1  flags-0x2

 ===============

> It would be great if there are any examples on user space communication.



Bug Thomas - he has written some simple example. I also have some but i
 changed laptops and i have to go and dig it up for you.
 I do have plans for making this easier for people - but havent had time.
 If there is persistence - or someone out there wants to be a hero email
 me privately and i will explain it.

> Or should I use libnl library instead?

Why am i answering all these questions if you are fine with using libnl?
Last time you said you couldnt use a library, no?

cheers,
jamal


> Thanks,
> Rui.
>
