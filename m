From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] tun driver use private linked list.
Date: Tue, 21 Oct 2003 08:55:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20031021085410.05203418@unixmail.qualcomm.com>
References: <5.1.0.14.2.20031009110604.05a541b0@unixmail.qualcomm.com>
 <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
 <20030808113404.0e9e1e6d.shemminger@osdl.org>
 <200308051630.28552.bellucda@tiscali.it>
 <20030805090647.691daa7e.shemminger@osdl.org>
 <200308051910.55823.bellucda@tiscali.it>
 <20030807154524.4794ad45.shemminger@osdl.org>
 <20030807155901.49f1a424.davem@redhat.com>
 <20030808113404.0e9e1e6d.shemminger@osdl.org>
 <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
 <5.1.0.14.2.20031009110604.05a541b0@unixmail.qualcomm.com> <20031009125929.6f2d99f9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031009125929.6f2d99f9.shemminger@osdl.org>
References: <5.1.0.14.2.20031009110604.05a541b0@unixmail.qualcomm.com>
 <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
 <20030808113404.0e9e1e6d.shemminger@osdl.org>
 <200308051630.28552.bellucda@tiscali.it>
 <20030805090647.691daa7e.shemminger@osdl.org>
 <200308051910.55823.bellucda@tiscali.it>
 <20030807154524.4794ad45.shemminger@osdl.org>
 <20030807155901.49f1a424.davem@redhat.com>
 <20030808113404.0e9e1e6d.shemminger@osdl.org>
 <5.1.0.14.2.20030812092213.08dc6ea0@unixmail.qualcomm.com>
 <5.1.0.14.2.20031009110604.05a541b0@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 12:59 PM 10/9/2003, Stephen Hemminger wrote:
>On Thu, 09 Oct 2003 11:45:31 -0700
>Max Krasnyansky <maxk@qualcomm.com> wrote:
>
>> Actually in case of persistent devices we can not let the module go away. Because it has
>> important info like user id of the owner and stuff which is not stored anywhere else. 
>> It also provides device name reservation, UML folks use it for example to reserve certain 
>> devices to a certain users. If module goes away admin will have to recreate those devices 
>> again. TUN/TAP devices are created in ioctl and since vfs layer already holds a reference, 
>> like you said, it's safe for us to just do __module_get()/module_put(). 
>
>I think letting the admin do what he requests is the right thing.  The philosophy of
>module unload has changed: with 2.4 it was "don't let admin unload the network
>element if anything is using it"; now it is "let the admin unload any module
>and cleanup as necessary".  
Yeah, I don't necessarily agree with that :). But I guess you can argue that 
only admin can unload the module. And he probably knows what he's doing.

Max
