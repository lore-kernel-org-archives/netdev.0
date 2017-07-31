From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ISDN: eicon: fix array-bounds warning properly
Date: Mon, 31 Jul 2017 22:29:50 +0200
Message-ID: <CAK8P3a2Tw9_L2Nd_J4vRKn0BGvw9R5opkj4eWGMS09qrJUSnug@mail.gmail.com>
References: <20170731090438.458392-1-arnd@arndb.de> <3d83ad3f-d47a-f43f-4180-d46fdae54bd7@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Armin Schindler <mac@melware.de>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3d83ad3f-d47a-f43f-4180-d46fdae54bd7@linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2017 at 9:38 PM,  <isdn@linux-pingi.de> wrote:
> Hi Arnd,
>
> I think you are right, but removing this is maybe the wrong fix.
>
> The issue is, that CAPI messages are packed byte streams and yes the
> 64bit extension of CAPI is not very good designed for modern CPU
> constrains with alignment, since the data pointer for the buffer is not
> on a 64bit boundary.

I also attempted to just mark the pointer as __packed, which would address
the warning as well, but then I saw that no code refers to it.

> All hardware controller implementations I know do
> ignore the data pointer, they are simple awaiting the data of the given
> length directly after the message. Only the application interface on 64
> bit systems really need the 64 bit data pointer value, which is usually
> set in the HW driver to the mapped user space address of the used data
> buffer if the user space process is 64bit.
> The user space CAPI library correctly use byte stream access functions
> to read/write the values. So the correct solution for this driver would
> be to use stream access functions as well here and not add a 64 bit
> pointer.

I'm not sure what change you are proposing here.

> On the other hand I do not think the any people use this driver on 64
> bit systems today, because they would run into this issue.

Right. Another way of addressing the warning would be to add a
'depends on BROKEN || !64BIT' dependency in Kconfig, which
would serve to document the fact that it's broken and prevent
us from running into it.

        Arnd
