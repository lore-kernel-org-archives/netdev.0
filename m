From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: very strange inet_sock corruption with rpc
Date: Thu, 26 Apr 2007 08:52:34 -0400
Message-ID: <4630A092.8000504@hp.com>
References: <462FC238.4040305@hp.com> <1177539237.21594.3.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:58557 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566AbXDZMwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 08:52:42 -0400
In-Reply-To: <1177539237.21594.3.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
>> The corruption is triggered after about 10 minutes of running the following
>> script:
>>
>> nfspath = $1
>> localpath = $2
>> while true; do
>> 	mount "$nfspath" "$localpath"
>> 	sleep 5
>> 	cp /boot/vmlinuz "$localpath"
>> 	sleep 5
>> 	rm $localpath/vmlinuz
>> 	sleep 5
>> 	umount "$localpath"
>> done
>>
>>
>> And looks like this:
>>
>> sk2 might be corrupt.  Info:
>>         sk2 = ffff8100f004d080
>>         tb->port = 844
>>         inet_sk(sk2)->num = 61695
>>         inet_sk(sk2)->foo = 24242424243f243f
>>         inet_sk(sk2)->bar = 3f24243f
>> BUG: at net/ipv4/inet_connection_sock.c:58 inet_csk_bind_conflict()
>>
>> Call Trace:
>>  [<ffffffff803cc591>] inet_csk_bind_conflict+0xcb/0x178
>>  [<ffffffff803cc4c6>] inet_csk_bind_conflict+0x0/0x178
>>  [<ffffffff803cc2ff>] inet_csk_get_port+0x11a/0x1ef
>>  [<ffffffff803ddf51>] inet_bind+0x117/0x1f5
>>  [<ffffffff88184e13>] :sunrpc:xs_bindresvport+0x4e/0xbf
>>  [<ffffffff881853a4>] :sunrpc:xs_tcp_connect_worker+0x0/0x2a0
>>  [<ffffffff88185433>] :sunrpc:xs_tcp_connect_worker+0x8f/0x2a0
> 
> If you are using NFS over UDP, why is a TCP routine
> getting called by sunrpc?

No clue. ;)  My guess is that is has something to do with RPC
itself, but this is the question I keep asking myself as well.
I don't have an answer for it yet.

Just for completeness, here is the mount line from fstab:

host:/export   /mnt      nfs soft,noatime,rsize=8192,wsize=8192,timeo=14,intr,auto 0     0

-vlad

> 
>>  [<ffffffff80248bd3>] run_workqueue+0x8f/0x137
>>  [<ffffffff80245687>] worker_thread+0x0/0x14a
>>  [<ffffffff8024579b>] worker_thread+0x114/0x14a
>>  [<ffffffff8027e544>] default_wake_function+0x0/0xe
>>  [<ffffffff8022ff49>] kthread+0xd1/0x100
>>  [<ffffffff80258f68>] child_rip+0xa/0x12
>>  [<ffffffff8022fe78>] kthread+0x0/0x100
>>  [<ffffffff80258f5e>] child_rip+0x0/0x12

