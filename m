From: Zhang Rui <rui.zhang@intel.com>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Thu, 14 Jun 2007 16:59:36 +0800
Message-ID: <1181811576.5411.27.camel@localhost.localdomain>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-56+fTiSz5UpqtEDsbG20"
Cc: netdev@vger.kernel.org, linux-acpi@vger.kernel.org, lenb@kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-56+fTiSz5UpqtEDsbG20
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi, Jamal,

Now the genl utility can find the acpi event genetlink family.
And a simple user space demo is finished for handling acpi event.
I really appreciate your help. :)

I think the patch which exposes ACPI events via netlink is ok.
But I still have some problems on
how to listen to specified genetlink family in user space?

I can get the dynamic id for "acpi_event" genl family.
But I don't know how to use this to receive messages from
specified genl family.
It seems that "#genl ctrl monitor" has something to do with this,
IMO, rtnl_open_byproto(&rth, nl_mgrp(GENL_ID_CTRL), NETLINK_GENERIC) is
used to receive messages from the nlctrl(controller) only, but
unfortunately it never works for me. :(

Any suggestions? What interfaces should I use? Or where can I find some
example code?

Attachment is the simple user space demo I made.
It receives all the broadcasted genetlink messages and only parses the
ones sent by "acpi_event" genl family.


Thanks,
Rui

On Sun, 2007-05-27 at 09:34 -0400, jamal wrote: 
> On 5/27/07, Zhang Rui <rui.zhang@intel.com> wrote:
> >
> > I need to write a user application to test my patch.
> > Netlink messages can be sent/received using the standard socket API.
> 
> sure.
> 
> > But how to receive Genetlink messages from specified genetlink family?
> > There is no socket ACPI with such a parameter, right?
> 
> Each module has a unique identifier that it receives dynamically on
>  insertion at the kernel.
> 
> > Do I have to receive all the genetlink messages first?
> 
>  No, just the ones for your dynamic id. Try what i described first for
>  kernel side on the earlier email. I will repeat it here for clarity.
> Then look at genl code and if you have questions i can
>  help.
> Note: You need to discover your dynamic id (the iproute2/genl code has a stub
> example code)
>  As i told you in the earlier email, in your development:
>  - start first by just writting your kernel side.
>  - Then use the genl utility - which is part of iproute2 to see if the
>  kernel side is "discoverable".
> 
>  E.g if i wanted to "discover" currently loaded modules on my laptop, i
>  would do this:
> 
>  ---------------
>  hadi@lilsol:~$ genl ctrl ls
> 
>  Name: nlctrl
>          ID: 0x10  Version: 0x2  header size: 0  max attribs: 6
>          commands supported:
>                  #1:  ID-0x3  flags-0xe
> 
> 
>  Name: nl80211
>          ID: 0x11  Version: 0x1  header size: 0  max attribs: 22
>          commands supported:
>                  #1:  ID-0x1  flags-0xa
>                  #2:  ID-0x6  flags-0xa
>                  #3:  ID-0x8  flags-0xa
>                  #4:  ID-0x3  flags-0xb
>                  #5:  ID-0x4  flags-0xb
>                  #6:  ID-0x5  flags-0xb
>                  #7:  ID-0xa  flags-0xb
>                  #8:  ID-0xb  flags-0xa
>                  #9:  ID-0xf  flags-0xb
>                  #10:  ID-0x10  flags-0xa
>                  #11:  ID-0x12  flags-0xb
>                  #12:  ID-0x13  flags-0xa
>                  #13:  ID-0x15  flags-0xa
>                  #14:  ID-0x19  flags-0xb
>                  #15:  ID-0x17  flags-0xb
>                  #16:  ID-0x18  flags-0xb
>                  #17:  ID-0x1a  flags-0xb
>                  #18:  ID-0x1b  flags-0xa
>                  #19:  ID-0xd  flags-0xb
> 
> 
>  Name: TASKSTATS
>          ID: 0x12  Version: 0x1  header size: 0  max attribs: 4
>          commands supported:
>                  #1:  ID-0x1  flags-0xa
>  ---------------------------
> 
>  As you can see, i can see from user space the name of the kernel end
>  point, its numeric id, what version it is running (so i can make sure
>  user space is compatible), what extra header it may have, what the
>  maximum number of attributes it can take. The last thing that gets
>  listed is the commands, and flags for those commands.
> 
>  Lets load tipc kernel module and repeat...
> 
>  -----------
> 
>  hadi@lilsol:~$ sudo modprobe tipc
>  Name: nlctrl
>          ID: 0x10  Version: 0x2  header size: 0  max attribs: 6
>          commands supported:
>                  #1:  ID-0x3  flags-0xe
> 
>  ....
>  [same as before]
>  ....
> 
>  Name: TIPC
>          ID: 0x13  Version: 0x1  header size: 8  max attribs: 0
>          commands supported:
>                  #1:  ID-0x1  flags-0x2
> 
>  ===============
> 
> > It would be great if there are any examples on user space communication.
> 
> 
> 
> Bug Thomas - he has written some simple example. I also have some but i
>  changed laptops and i have to go and dig it up for you.
>  I do have plans for making this easier for people - but havent had time.
>  If there is persistence - or someone out there wants to be a hero email
>  me privately and i will explain it.
> 
> > Or should I use libnl library instead?
> 
> Why am i answering all these questions if you are fine with using libnl?
> Last time you said you couldnt use a library, no?
> 
> cheers,
> jamal
> 
> 
> > Thanks,
> > Rui.
> >

--=-56+fTiSz5UpqtEDsbG20
Content-Disposition: attachment; filename=acpi_genl.tgz
Content-Type: application/x-compressed-tar; name=acpi_genl.tgz
Content-Transfer-Encoding: base64

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
fs2v+TW/5tf8+rmvfwHxNfKGAKAAAE==


--=-56+fTiSz5UpqtEDsbG20--
