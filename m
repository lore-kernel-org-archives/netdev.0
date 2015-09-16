From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Wed, 16 Sep 2015 07:57:30 -0600
Message-ID: <55F9754A.1030507@cumulusnetworks.com>
References: <20150916092447.GA945@swordfish> <55F9578C.40209@ericsson.com>
 <55F9699E.5080807@cumulusnetworks.com> <55F97459.5050408@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Richard Alpe <richard.alpe@ericsson.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55F97459.5050408@ericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/16/15 7:53 AM, Richard Alpe wrote:
>>> I to get an Oops in ip_route_input_noref(). It happens occasionally during bootup.
>>> KVM environment using virtio driver. Let me know if you need any additional info or
>>> if you want me to try to bisect it.
>>>
>>> Starting network...
>>> ...
>>> [    0.877040] BUG: unable to handle kernel NULL pointer dereference at 0000000000000056
>>> [    0.877597] IP: [<ffffffff8155b5e2>] ip_route_input_noref+0x1a2/0xb00
>>
>> Can you send me your kernel config and qemu command line? KVM with virtio networking is a primary test vehicle, and I did not encounter this at all.
> Sure thing. Not sure how ppl normally provide files on netdev but I'm just going
> to go ahead and paste them here :)

An attachment for the config is better than inline.

>
> $ ps aux | grep kvm
> qemu-system-x86_64 -enable-kvm -name tipc-medium-node1 -S -machine pc-0.14,accel=kvm,usb=off -m 1024 -realtime mlock=off -smp 2,sockets=2,cores=1,threads=1 -uuid cdec478a-5f0d-49f1-b25e-fac4ca0b290c -no-user-config -nodefaults -chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/tipc-medium-node1.monitor,server,nowait -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc -no-shutdown -boot order=n,menu=on,strict=on -device piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2 -netdev tap,fd=25,id=hostnet0 -device e1000,netdev=hostnet0,id=net0,mac=00:0f:ff:10:04:01,bus=pci.0,addr=0x3 -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -vnc 127.0.0.1:28101 -device cirrus-vga,id=video0,bus=pci.0,addr=0x2 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x
 4 -msg timestamp=on
>
> $ cat .config
> #
> # Automatically generated file; DO NOT EDIT.
> # Linux/x86 3.12.28 Kernel Configuration
> #

3.12.28? That should say this for net-next:

# Linux/x86 4.2.0 Kernel Configuration

Or are you reporting a problem with 3.12.28?

David
