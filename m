From: manio <manio@skyboo.net>
Subject: Re: [PATCH 2.6.21.1] nfs-root: added possibility to override default
 MTU (for UDP jumbo frames)
Date: Mon, 02 Jul 2007 18:27:44 +0200
Message-ID: <46892780.5060703@skyboo.net>
References: <E1I5LAW-0004Dn-8b@skyboo.net> <4688FA00.5050801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756059AbXGBQ17@vger.kernel.org>
In-Reply-To: <4688FA00.5050801@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Staubach wrote:
> manio@skyboo.net wrote:
>> To use a NFS-root for UDP jumbo frames the kernel on the client need 
>> to bring
>> up interface with MTU set to 9000 bytes - otherwise it cannot contact 
>> server
>> with jumbo frames enabled (nfs server not responding, still trying) 
>> and cannot
>> boot. Added a kernel parameter named 'ipmtu' which can be used to 
>> specify
>> initial MTU size when booting via nfsroot.
>>
>>   
>
> Could you describe the problem better, please?  Something does not
> sound right.  Both ends need to have jumbo frames enabled in order
> to use jumbo frames, but if one end or the other does not, the systems
> still should be able to exchange packets using normal sized ethernet
> packets.  Isn't this a problem that mtu discovery should handle?
>
>    Thanx...
>
>       ps
ok - first of all: yes you're right - if both ends have jumbo frames 
enabled
it is all working fine - the patch is just for enabling client's MTU to 
jumbo
because when booting via NFS-root client's MTU is set to default (1500
in ethernet case). I know that when server has MTU=9000 and client=1500
it should work - but it only work when nfs-root directory is mounted with
TCP protocol. But i mean using UDP frames (then nfs options: wsize and
rsize could be 8192 bytes).

If I'm not clear I'll give you simple example:
My server has jumbo frames enabled (it's not a problem to set it because
server has HDD - can set up MTU during run time).
The problem is when my diskless client need to boot via nfs-root.
With vanilla kernel it looks like this:
1. Client boots
2. PXE get address from DHCP
3. without problem PXE client get kernel from server (via tftpboot)
4. it stop when kernel is going to mount root filesystem from NFS
it still trying because server has jumbo enabled and client doesn't
(endless message: NFS server is not responding, still trying)

If I pass the ipmtu option with 9000 value to client's patched kernel then
all is working fine because both client and server has jumbo frames
enabled and client is able to mount root filesystem via NFS from server.

the problem was some time ago posted by Tupshin Harper:
http://www.ussg.iu.edu/hypermail/linux/kernel/0311.1/1055.html

... and is also described on my webpage:
http://manio.skyboo.net/nfsroot_jumbo/

i hope you know what's going on :)

best regards,
Mariusz Bialonczyk
