From: Stephen Buck <stephen.buck@exinda.com>
Subject: Re: tproxy related crash in inet_hashtables
Date: Sat, 14 Aug 2010 14:35:21 +1000
Message-ID: <4C661D09.8030709@exinda.com>
References: <4C64FF2E.6060509@exinda.com>	 <1281696852.4470.20.camel@edumazet-laptop>  <4C65432F.4030809@exinda.com> <1281707736.4470.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060503060400010800090306"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@sch.bme.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1281707736.4470.53.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060503060400010800090306
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

  On 13/08/10 23:55, Eric Dumazet wrote:
> Le vendredi 13 août 2010 à 23:05 +1000, Stephen Buck a écrit :
>> On 13/08/10 20:54, Eric Dumazet wrote:
>>> Le vendredi 13 août 2010 à 18:15 +1000, Stephen Buck a écrit :
>>>> Recently I encountered a number of crashes related to tproxy on the
>>>> 2.6.34.1 (x86_64 SMP) kernel. These usually manifested as a bug like the
>>>> following (Although the bug was confirmed to be present on a vanilla
>>>> kernel, this particular trace is from a kernel with some customisations):
>>>>
>>>> [ 1504.765077] BUG: unable to handle kernel NULL pointer dereference at
>>>> (null)
>>>> [ 1504.848183] IP: [<ffffffff8135a79b>] inet_bind_bucket_destroy+0x1b/0x30
>>>> [ 1504.927126] PGD 1a9933067 PUD 1ad909067 PMD 0
>>>> [ 1504.980125] Thread overran stack, or stack corrupted
>>>> [ 1505.039325] Oops: 0002 #1 SMP
>>>> [ 1505.077775] last sysfs file:
>>>> /sys/devices/system/cpu/cpu15/topology/thread_siblings
>>>> [ 1505.169166] CPU 0
>>>> [ 1505.193070] Modules linked in: sch_sfq cls_fw sch_htb xt_physdev
>>>> 8021q bridge stp llc
>>>> [ 1505.923769] Pid: 0, comm: swapper Not tainted 2.6.31-12EXINDAsmp #0
>>>> PowerEdge R710
>>>> [ 1506.014118] RIP: 0010:[<ffffffff8135a79b>] [<ffffffff8135a79b>]
>>>> inet_bind_bucket_destroy+0x1b/0x30
>>>> [ 1506.122242] RSP: 0018:ffffc90000003e10 EFLAGS: 00010246
>>>> [ 1506.185655] RAX: 0000000000000000 RBX: ffffc900164a02a0 RCX:
>>>> ffffea00098e24b0
>>>> [ 1506.270863] RDX: 0000000000000000 RSI: ffff8802e1186280 RDI:
>>>> ffffffff815b4600
>>>> [ 1506.356077] RBP: ffffc90000003e10 R08: 0000000000000016 R09:
>>>> 0000000000000001
>>>> [ 1506.441284] R10: 0000000000000000 R11: 0000000000000000 R12:
>>>> ffff88011b894fc0
>>>> [ 1506.526500] R13: ffffffff81744c80 R14: ffffffff815fe6c0 R15:
>>>> 0000000000000003
>>>> [ 1506.611722] FS: 0000000000000000(0000) GS:ffffc90000000000(0000)
>>>> knlGS:0000000000000000
>>>> [ 1506.708410] CS: 0010 DS: 0018 ES: 0018 CR0: 000000008005003b
>>>> [ 1506.777011] CR2: 0000000000000000 CR3: 00000001ae17a000 CR4:
>>>> 00000000000006f0
>>>> [ 1506.862225] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>>>> 0000000000000000
>>>> [ 1506.947442] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>>>> 0000000000000400
>>>> [ 1507.032650] Process swapper (pid: 0, threadinfo ffffffff815b0000,
>>>> task ffffffff815b6bc0)
>>>> [ 1507.129345] Stack:
>>>> [ 1507.153299] ffffc90000003e40 ffffffff8135b834 0000000000000001
>>>> ffff88011b894fc0
>>>> [ 1507.239581]<0>   ffffffff815fe560 0000000000000002 ffffc90000003e80
>>>> ffffffff8135bbf6
>>>> [ 1507.331133]<0>   ffffffff815fe560 ffffffff815fe560 ffffffff815fe6c0
>>>> ffffc90000003eb0
>>>> [ 1507.424833] Call Trace:
>>>> [ 1507.453976]<IRQ>
>>>> [ 1507.478971] [<ffffffff8135b834>] __inet_twsk_kill+0xb4/0xf0
>>>> [ 1507.546538] [<ffffffff8135bbf6>] inet_twdr_do_twkill_work+0x66/0xd0
>>>> [ 1507.622408] [<ffffffff8135bd40>] ? inet_twdr_hangman+0x0/0xd0
>>>> [ 1507.692041] [<ffffffff8135bd95>] inet_twdr_hangman+0x55/0xd0
>>>> [ 1507.760650] [<ffffffff810515ec>] run_timer_softirq+0x18c/0x220
>>>> [ 1507.831330] [<ffffffff8104c3b8>] __do_softirq+0xc8/0x1f0
>>>> [ 1507.895799] [<ffffffff8100cf5c>] call_softirq+0x1c/0x30
>>>> [ 1507.959209] [<ffffffff8100e5f5>] do_softirq+0x45/0x80
>>>> [ 1508.020538] [<ffffffff8104c2e7>] irq_exit+0x87/0x90
>>>> [ 1508.079797] [<ffffffff813bd0c1>] smp_apic_timer_interrupt+0x71/0x9d
>>>> [ 1508.155667] [<ffffffff8100c933>] apic_timer_interrupt+0x13/0x20
>>>> [ 1508.227385]<EOI>
>>>> [ 1508.252383] [<ffffffff8101317e>] ? mwait_idle+0x7e/0x110
>>>> [ 1508.316836] [<ffffffff813bb0bd>] ? __atomic_notifier_call_chain+0xd/0x10
>>>> [ 1508.397903] [<ffffffff813bb0d1>] ? atomic_notifier_call_chain+0x11/0x20
>>>> [ 1508.477928] [<ffffffff8100ac31>] ? cpu_idle+0x51/0x90
>>>> [ 1508.539265] [<ffffffff813aa92b>] ? rest_init+0x6b/0x80
>>>> [ 1508.601639] [<ffffffff816230f5>] ? start_kernel+0x2c5/0x370
>>>> [ 1508.669200] [<ffffffff81622611>] ? x86_64_start_reservations+0x81/0xc0
>>>> [ 1508.748192] [<ffffffff81622726>] ? x86_64_start_kernel+0xd6/0x100
>>>> [ 1508.821979] Code: 64 10 40 eb 94 0f 1f 44 00 00 66 0f 1f 44 00 00 55
>>>> 48 89 e5 0f 1f 44 00 00 48 83 7e 18 00 75 19 48 8b 46 08 48 8b 56 10
>>>> [ 1509.048123] RIP [<ffffffff8135a79b>] inet_bind_bucket_destroy+0x1b/0x30
>>>> [ 1509.128157] RSP<ffffc90000003e10>
>>>> [ 1509.169759] CR2: 0000000000000000
>>>>
>>>>
>>>> After spending a while tracking it down, I discovered that the wrong
>>>> locks get held when operating on the bind hash table's chains.
>>>>
>>>> This is due to the listen socket and the child socket having different
>>>> local ports when __inet_inherit_port() is called. The lock is held based
>>>> on the child socket's port, but the list operated on is the one the
>>>> listen socket belongs to.
>>>>
>>>> e.g.
>>>> There is a transparent proxy listening on port 9999.
>>>> A new http connection (with port 80) is redirected to the proxy.
>>>>
>>>> The inet_bind_hashbucket locked in this case is table->bhash[80].lock,
>>>> but the inet_bind_bucket the child socket is added to is in the chain of
>>>> the table->bhash[9999] inet_bind_hashbucket. This means that if another
>>>> connection with a different local port arrived and was redirected to the
>>>> proxy, they could both be operating on the list at the same time.
>>>>
>>>>
>>>> Attached is a patch that should fix this by looking up the correct
>>>> inet_bind_bucket based on the child's local port when the
>>>> inet_bind_bucket from the listen socket has a different port to the
>>>> child's inet_num. It was built against 2.6.34.1, but should apply to any
>>>> mainline kernel.
>>>>
>>>> It is also possible the same bug exists in the IPv6 code as well. As I
>>>> have not had to deal with IPv6 yet, I have not had a look.
>>> Hi Stephen
>>>
>>> CC netfilter-devel&   Patrick&   Krisztian
>>>
>>> I cannot convince myself this patch is a right fix.
>>>
>>> This probably should be fixed in netfilter tree, not in
>>> net/ipv4/inet_hashtables.c ?
>>>
>>> Once tproxy is involved, the original port (80) should be changed to
>>> 9999 by tproxy (for SYN packet) and conntrack for following ones.
>>>
>>> So listening socket and its children all use source port 9999 ?
>>>
>>> (inet_sk(child)->inet_num == inet_sk(parent)->inet_num)
>> I think you are referring to the older method of transparent proxying.
>> Tproxy4 does not rely on conntrack. The socket is created with the
>> connection's original ports and IPs.
> So in your case "netstat -atn" displays port 80 , not port 9999 for
> children, and 9999 for the listener ?
Yes, that is correct.
>>> You claim wrong lock is taken at insert time, but are you sure the right
>>> lock is taken at deletion time ?
>>>
>>> Hmm...
>>>
>> Without the patch, you have the same problem in __inet_put_port(). The
>> lock is taken based on the child's inet_num, but the icsk_bind_hash of
>> the socket was inherited from the parent, so it belongs to a different
>> inet_bind_hashbucket.
>>
>> With the patch, inet_bind_hash refers to the inet_bind_bucket that was
>> found by searching the hash table, rather than directly inherited from
>> the parent. This means that the correct lock is chosen for the list
>> being manipulated.
> Really ?
>
> So lock[80] is taken at insert time (as your patch doesnt change
> locking), and lock[9999] taken at delete time ? How comes it doesnt
> race ?
No, lock[80] is taken at delete time. It is taken using the exact same 
procedure as in __inet_inherit_port().

The problem in __inet_put_sock() occurs when 
inet_csk(sk)->icsk_bind_hash->port != inet_sk(sk)->inet_num. With the 
patch, inet_csk(sk)->icsk_bind_hash->port == inet_sk(sk)->inet_num, so 
the locking is correct.

Below, I've attempted to walk through the original code. Hopefully it 
makes things a little clearer.

// inet_sk(sk)->inet_num = 9999
// inet_sk(child)->inet_num = 80
// inet_csk(sk)->icsk_bind_hash is a bucket where
//         inet_csk(sk)->icsk_bind_hash->port = 9999
// inet_csk(child)->icsk_bind_hash is uninitialised

void __inet_inherit_port(struct sock *sk, struct sock *child)
{
         struct inet_hashinfo *table = sk->sk_prot->h.hashinfo;
         const int bhash = inet_bhashfn(sock_net(sk), 
inet_sk(child)->inet_num,
                         table->bhash_size);

// head is retrieved usng inet_sk(child)->inet_num, so we end up with
// head = &table->bhash[80]

         struct inet_bind_hashbucket *head = &table->bhash[bhash];
         struct inet_bind_bucket *tb;

         spin_lock(&head->lock);

// Here the child is queued in the same list as the parent. This means that
// the child is queued in a inet_bind_bucket where
// inet_bind_bucket->port = 9999, but the lock being held is bhash[80].lock

         tb = inet_csk(sk)->icsk_bind_hash;
         sk_add_bind_node(child, &tb->owners);

// Now inet_csk(child)->icsk_bind_hash is assigned to the bucket where
// inet_bind_bucket->port = 9999 resulting in the wrong lock being taken
// for the list being manipulated in __inet_put_port()

         inet_csk(child)->icsk_bind_hash = tb;
         spin_unlock(&head->lock);
}

// inet_sk(sk)->inet_num = 9999
// inet_sk(child)->inet_num = 80
// inet_csk(sk)->icsk_bind_hash is a bucket where
//         inet_csk(sk)->icsk_bind_hash->port = 9999
// inet_csk(child)->icsk_bind_hash is a bucket where
//         inet_csk(sk)->icsk_bind_hash->port = 9999

It is the difference between inet_sk(child)->inet_num and 
inet_csk(child)->icsk_bind_hash->port that causes problems in 
__inet_put_port().

With the patch, inet_sk(child)->inet_num and 
inet_csk(child)->icsk_bind_hash are kept in sync eliminating the locking 
error in __inet_put_port().

> Look I am _very_ confused by this stuff.
>
> How can you explain lock is taken on table->bhash[80].lock but your
> patch adds a chain to table->bhash[9999] ? This is not what your patch
> is trying to do. Or you should lock table->bhash[9999].lock
>
The patch does not cause a inet_bind_hashbucket to be added to 
table->bhash[9999]. It is added (if it doesn't already exist) to 
table->bhash[80], so there is no problem with the locking.
> Please check the comment in front of inet_bind_bucket_create() :
>
> /*
>   * Allocate and initialize a new local port bind bucket.
>   * The bindhash mutex for snum's hash chain must be held here.
>   */
>
> Maybe change this comment, because clearly "snum's hash" meaning is very
> different after tproxy inclusion (and your patch) ?
I'm not sure I agree. The bindhash mutex for snum's hash is held, as 
described. The lock held is bhash[80], and snum is also 80, so the 
comment is correct.
> Your patch Changelog is not clear enough, or very misleading ...
>
> commit f517f61e37907ea66e48f224c135a9e1c257bb04
> Author: Stephen Buck<stephen.buck@exinda.com>
> Date:   Thu Aug 12 16:19:19 2010 +1000
>
>      Fix locking issue in inet_hashtables when using tproxy
>
>      When __inet_inherit_port() is called on a tproxy connection the wrong locks
>      are held for the inet_bind_bucket it is added to.
>
>
>
> Since your patch does nothing about the lock itself, but adds a
> new struct inet_bind_bucket in case the parent one is not appropriate, and
> another sibling is not yet present.
>
> I suggest you include in ChangeLog _all_ your email, because I am
> pretty sure nobody will understand the intent of your patch in 2011.
>
> I am sure the full explanation is better than a very short log entry.
Ok I've reworked the patch's comment to describe the problem in more 
detail and to describe more accurately what it actually does.
> Thanks
>

On a slight tangent, should tb->num_owners be incremented in 
__inet_inherit_port()? It is decremented in __inet_put_port(), causing 
the value to go strongly negative. My interpretation of what it should 
do is count the number of full (non-timewait) sockets in the owners list.

--------------060503060400010800090306
Content-Type: text/plain;
 name="tproxy-bind-fix.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="tproxy-bind-fix.patch"

Y29tbWl0IGVlZGNmOTdhY2E1YTFjNDgzNDc1MjE2Njk2ZDVlNzlmYTg2OGFiNjYKQXV0aG9y
OiBTdGVwaGVuIEJ1Y2sgPHN0ZXBoZW4uYnVja0BleGluZGEuY29tPgpEYXRlOiAgIFRodSBB
dWcgMTIgMTY6MTk6MTkgMjAxMCArMTAwMAoKICAgIFB1dCBhIHRwcm94eSBzb2NrZXQgaW4g
dGhlIGNvcnJlY3QgYmluZCBidWNrZXQKICAgIAogICAgV2hlbiBfX2luZXRfaW5oZXJpdF9w
b3J0KCkgaXMgY2FsbGVkIG9uIGEgdHByb3h5IGNvbm5lY3Rpb24sIHRoZSBwYXJlbnQncwog
ICAgaW5ldF9udW0gaXMgbm90IHRoZSBzYW1lIGFzIHRoZSBjaGlsZCdzIGluZXRfbnVtLiBU
aGlzIHJlc3VsdHMgaW4gdGhlIGNoaWxkCiAgICBzb2NrZXQgYmVpbmcgYWRkZWQgdG8gdGhl
IHdyb25nIGluZXRfYmluZF9idWNrZXQuCiAgICAKICAgIEluIGFkZGl0aW9uIHRvIHRoaXMs
IHRoZSBkaXNjcmVwZW5jeSBjYXVzZXMgdGhlIHdyb25nIGxvY2sgaXMgaGVsZCwgc28gdGhh
dAogICAgaWYgMiBjb25uZWN0aW9ucyB3aXRoIGRpZmZlcmVudCBkZXN0aW5hdGlvbiBwb3J0
cyBhcnJpdmUgYXQgdGhlIHNhbWUgdGltZSwgdGhlCiAgICBsaXN0IG1heSBiZSBjb3JydXB0
ZWQuIFNpbWlsYXJseSwgdGhlIHdyb25nIGxvY2sgaXMgaGVsZCB3aGVuIHRoZSBzb2NrZXQg
aXMKICAgIHJlbW92ZWQgZnJvbSB0aGUgYmluZCBoYXNoIGluIF9faW5ldF9wdXRfcG9ydCgp
LgogICAgCiAgICBXaGVuIHRoZSBwYXJlbnQncyBpbmV0X251bSBpcyBkaWZmZXJlbnQgdG8g
dGhlIGNoaWxkJ3MgaW5ldF9udW0sIHRoZQogICAgaW5ldF9iaW5kX2J1Y2tldCBuZWVkcyB0
byBiZSByZXRyaWV2ZWQgZGlyZWN0bHkgZnJvbSB0aGUgaGFzaCB0YWJsZS4KICAgIFRoaXMg
a2VlcHMgdGhlIGNoaWxkJ3MgaW5ldF9udW0gYW5kIGljc2tfYmluZF9oYXNoIGluIHN5bmMg
ZWxpbWluYXRpbmcgdGhlCiAgICBkZXNjcmliZWQgbG9ja2luZyBlcnJvcnMuCiAgICAKICAg
IEJlbG93IGlzIGEgd2FsayB0aHJvdWdoIHRoZSBvcmlnaW5hbCBjb2RlLCB1c2luZyBhIHNj
ZW5hcmlvIHdoZXJlIHRoZSB0cHJveHkKICAgIGxpc3RlbiBzb2NrZXQgaXMgYm91bmQgdG8g
cG9ydCA5OTk5LCBhbmQgaGFzIGEgbmV3IGh0dHAgY29ubmVjdGlvbiByZWRpcmVjdGVkCiAg
ICB0byBpdDoKICAgIAogICAgLy8gaW5ldF9zayhzayktPmluZXRfbnVtID0gOTk5OQogICAg
Ly8gaW5ldF9zayhjaGlsZCktPmluZXRfbnVtID0gODAKICAgIC8vIGluZXRfY3NrKHNrKS0+
aWNza19iaW5kX2hhc2ggaXMgYSBidWNrZXQgd2hlcmUKICAgIC8vICAgICAgICAgaW5ldF9j
c2soc2spLT5pY3NrX2JpbmRfaGFzaC0+cG9ydCA9IDk5OTkKICAgIC8vIGluZXRfY3NrKGNo
aWxkKS0+aWNza19iaW5kX2hhc2ggaXMgdW5pbml0aWFsaXNlZAogICAgCiAgICB2b2lkIF9f
aW5ldF9pbmhlcml0X3BvcnQoc3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3Qgc29jayAqY2hpbGQp
CiAgICB7CiAgICAJc3RydWN0IGluZXRfaGFzaGluZm8gKnRhYmxlID0gc2stPnNrX3Byb3Qt
PmguaGFzaGluZm87CiAgICAJY29uc3QgaW50IGJoYXNoID0gaW5ldF9iaGFzaGZuKHNvY2tf
bmV0KHNrKSwgaW5ldF9zayhjaGlsZCktPmluZXRfbnVtLAogICAgCQkJdGFibGUtPmJoYXNo
X3NpemUpOwogICAgCiAgICAvLyBoZWFkIGlzIHJldHJpZXZlZCB1c2luZyBpbmV0X3NrKGNo
aWxkKS0+aW5ldF9udW0sIHNvIHdlIGVuZCB1cCB3aXRoCiAgICAvLyBoZWFkID0gJnRhYmxl
LT5iaGFzaFs4MF0KICAgIAogICAgCXN0cnVjdCBpbmV0X2JpbmRfaGFzaGJ1Y2tldCAqaGVh
ZCA9ICZ0YWJsZS0+Ymhhc2hbYmhhc2hdOwogICAgCXN0cnVjdCBpbmV0X2JpbmRfYnVja2V0
ICp0YjsKICAgIAogICAgCXNwaW5fbG9jaygmaGVhZC0+bG9jayk7CiAgICAKICAgIC8vIEhl
cmUgdGhlIGNoaWxkIGlzIHF1ZXVlZCBpbiB0aGUgc2FtZSBsaXN0IGFzIHRoZSBwYXJlbnQu
IFRoaXMgbWVhbnMgdGhhdAogICAgLy8gdGhlIGNoaWxkIGlzIHF1ZXVlZCBpbiBhIGluZXRf
YmluZF9idWNrZXQgd2hlcmUKICAgIC8vIGluZXRfYmluZF9idWNrZXQtPnBvcnQgPSA5OTk5
LCBidXQgdGhlIGxvY2sgYmVpbmcgaGVsZCBpcyBiaGFzaFs4MF0ubG9jawogICAgCiAgICAJ
dGIgPSBpbmV0X2NzayhzayktPmljc2tfYmluZF9oYXNoOwogICAgCXNrX2FkZF9iaW5kX25v
ZGUoY2hpbGQsICZ0Yi0+b3duZXJzKTsKICAgIAogICAgLy8gTm93IGluZXRfY3NrKGNoaWxk
KS0+aWNza19iaW5kX2hhc2ggaXMgYXNzaWduZWQgdG8gdGhlIGJ1Y2tldCB3aGVyZQogICAg
Ly8gaW5ldF9iaW5kX2J1Y2tldC0+cG9ydCA9IDk5OTkgcmVzdWx0aW5nIGluIHRoZSB3cm9u
ZyBsb2NrIGJlaW5nIHRha2VuCiAgICAvLyBmb3IgdGhlIGxpc3QgYmVpbmcgbWFuaXB1bGF0
ZWQgaW4gX19pbmV0X3B1dF9wb3J0KCkKICAgIAogICAgCWluZXRfY3NrKGNoaWxkKS0+aWNz
a19iaW5kX2hhc2ggPSB0YjsKICAgIAlzcGluX3VubG9jaygmaGVhZC0+bG9jayk7CiAgICB9
CiAgICAKICAgIC8vIGluZXRfc2soc2spLT5pbmV0X251bSA9IDk5OTkKICAgIC8vIGluZXRf
c2soY2hpbGQpLT5pbmV0X251bSA9IDgwCiAgICAvLyBpbmV0X2NzayhzayktPmljc2tfYmlu
ZF9oYXNoIGlzIGEgYnVja2V0IHdoZXJlCiAgICAvLyAgICAgICAgIGluZXRfY3NrKHNrKS0+
aWNza19iaW5kX2hhc2gtPnBvcnQgPSA5OTk5CiAgICAvLyBpbmV0X2NzayhjaGlsZCktPmlj
c2tfYmluZF9oYXNoIGlzIGEgYnVja2V0IHdoZXJlCiAgICAvLyAgICAgICAgIGluZXRfY3Nr
KHNrKS0+aWNza19iaW5kX2hhc2gtPnBvcnQgPSA5OTk5CgpkaWZmIC0tZ2l0IGEvbmV0L2lw
djQvaW5ldF9oYXNodGFibGVzLmMgYi9uZXQvaXB2NC9pbmV0X2hhc2h0YWJsZXMuYwppbmRl
eCAyYjc5Mzc3Li4xYmE5ODJmIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9pbmV0X2hhc2h0YWJs
ZXMuYworKysgYi9uZXQvaXB2NC9pbmV0X2hhc2h0YWJsZXMuYwpAQCAtMTA1LDEzICsxMDUs
MjQgQEAgRVhQT1JUX1NZTUJPTChpbmV0X3B1dF9wb3J0KTsKIHZvaWQgX19pbmV0X2luaGVy
aXRfcG9ydChzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBzb2NrICpjaGlsZCkKIHsKIAlzdHJ1
Y3QgaW5ldF9oYXNoaW5mbyAqdGFibGUgPSBzay0+c2tfcHJvdC0+aC5oYXNoaW5mbzsKLQlj
b25zdCBpbnQgYmhhc2ggPSBpbmV0X2JoYXNoZm4oc29ja19uZXQoc2spLCBpbmV0X3NrKGNo
aWxkKS0+aW5ldF9udW0sCisJdW5zaWduZWQgc2hvcnQgcG9ydCA9IGluZXRfc2soY2hpbGQp
LT5pbmV0X251bTsKKwljb25zdCBpbnQgYmhhc2ggPSBpbmV0X2JoYXNoZm4oc29ja19uZXQo
c2spLCBwb3J0LAogCQkJdGFibGUtPmJoYXNoX3NpemUpOwogCXN0cnVjdCBpbmV0X2JpbmRf
aGFzaGJ1Y2tldCAqaGVhZCA9ICZ0YWJsZS0+Ymhhc2hbYmhhc2hdOwogCXN0cnVjdCBpbmV0
X2JpbmRfYnVja2V0ICp0YjsKIAogCXNwaW5fbG9jaygmaGVhZC0+bG9jayk7CiAJdGIgPSBp
bmV0X2NzayhzayktPmljc2tfYmluZF9oYXNoOworCWlmICh0Yi0+cG9ydCAhPSBwb3J0KSB7
CisJCXN0cnVjdCBobGlzdF9ub2RlICpub2RlOworCQlpbmV0X2JpbmRfYnVja2V0X2Zvcl9l
YWNoKHRiLCBub2RlLCAmaGVhZC0+Y2hhaW4pIHsKKwkJCWlmIChuZXRfZXEoaWJfbmV0KHRi
KSwgc29ja19uZXQoc2spKSAmJiB0Yi0+cG9ydCA9PSBwb3J0KQorCQkJCWJyZWFrOworCQl9
CisJCWlmICghbm9kZSkKKwkJCXRiID0gaW5ldF9iaW5kX2J1Y2tldF9jcmVhdGUodGFibGUt
PmJpbmRfYnVja2V0X2NhY2hlcCwKKwkJCQkJCSAgICAgc29ja19uZXQoc2spLCBoZWFkLCBw
b3J0KTsKKwl9CiAJc2tfYWRkX2JpbmRfbm9kZShjaGlsZCwgJnRiLT5vd25lcnMpOwogCWlu
ZXRfY3NrKGNoaWxkKS0+aWNza19iaW5kX2hhc2ggPSB0YjsKIAlzcGluX3VubG9jaygmaGVh
ZC0+bG9jayk7Cg==
--------------060503060400010800090306--
