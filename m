From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: WARNING: CPU: 1 PID: 19544 at
	net/bridge/br_fdb.c:109 br_fdb_find+0x19d/0x1b0
Date: Wed, 15 Mar 2017 21:19:04 -0700
Message-ID: <CAM_iQpVoupZGkrUZu2ossrW8uOdQ9uT9FYLybBqh6qi205w54g@mail.gmail.com>
References: <CANaxB-zhLdJLz1AHdensX_zfQ7O3rzjhJn5eSTWC1tUAk2axTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11444a5ebf33b2054ad15daf
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Andrei Vagin <avagin@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CANaxB-zhLdJLz1AHdensX_zfQ7O3rzjhJn5eSTWC1tUAk2axTA@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--001a11444a5ebf33b2054ad15daf
Content-Type: text/plain; charset=UTF-8

On Wed, Mar 15, 2017 at 6:12 PM, Andrei Vagin <avagin@gmail.com> wrote:
> Hello,
>
> We execute CRIU tests for linux-next and here is a new warning:
> [  178.930950] ------------[ cut here ]------------
> [  178.930960] WARNING: CPU: 1 PID: 19544 at net/bridge/br_fdb.c:109
> br_fdb_find+0x19d/0x1b0
> [  178.930961] Modules linked in:
> [  178.930966] CPU: 1 PID: 19544 Comm: criu Not tainted
> 4.11.0-rc1-next-20170310 #1
> [  178.930968] Hardware name: Google Google Compute Engine/Google
> Compute Engine, BIOS Google 01/01/2011
> [  178.930970] Call Trace:
> [  178.930976]  dump_stack+0x85/0xc9
> [  178.930982]  __warn+0xd1/0xf0
> [  178.930988]  warn_slowpath_null+0x1d/0x20
> [  178.930990]  br_fdb_find+0x19d/0x1b0
> [  178.930994]  br_fdb_change_mac_address+0x38/0x80
> [  178.930999]  br_stp_change_bridge_id+0x44/0x140
> [  178.931003]  br_dev_newlink+0x3f/0x70
> [  178.931009]  rtnl_newlink+0x68e/0x830
> [  178.931014]  ? netlink_broadcast_filtered+0x134/0x3e0
> [  178.931025]  ? get_partial_node.isra.76+0x4b/0x2a0
> [  178.931032]  ? nla_parse+0xa3/0x100
> [  178.931035]  ? nla_strlcpy+0x5b/0x70
> [  178.931037]  ? rtnl_link_ops_get+0x39/0x50
> [  178.931040]  ? rtnl_newlink+0x158/0x830
> [  178.931064]  rtnetlink_rcv_msg+0x95/0x230
> [  178.931068]  ? rtnl_newlink+0x830/0x830
> [  178.931072]  netlink_rcv_skb+0xa7/0xc0
> [  178.931075]  rtnetlink_rcv+0x2a/0x40
> [  178.931078]  netlink_unicast+0x15b/0x210
> [  178.931082]  netlink_sendmsg+0x31a/0x3a0
> [  178.931089]  sock_sendmsg+0x38/0x50
> [  178.931092]  ___sys_sendmsg+0x26c/0x280
> [  178.931099]  ? __generic_file_write_iter+0x19b/0x1e0
> [  178.931105]  ? up_write+0x1f/0x40
> [  178.931110]  ? ext4_file_write_iter+0xa4/0x390
> [  178.931120]  __sys_sendmsg+0x45/0x80
> [  178.931126]  SyS_sendmsg+0x12/0x20
> [  178.931130]  entry_SYSCALL_64_fastpath+0x23/0xc2
> [  178.931132] RIP: 0033:0x2b71009f99a0
> [  178.931134] RSP: 002b:00007ffed7413c58 EFLAGS: 00000246 ORIG_RAX:
> 000000000000002e
> [  178.931137] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00002b71009f99a0
> [  178.931139] RDX: 0000000000000000 RSI: 00007ffed7413c90 RDI: 0000000000000002
> [  178.931140] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
> [  178.931142] R10: 00002b710180cfe0 R11: 0000000000000246 R12: 0000000000000001
> [  178.931144] R13: 0000000000000004 R14: 00007ffed74134b0 R15: 0000000000000003
> [  178.931152] ---[ end trace 61d5dd5e3b9abaf8 ]---
> [  178.931453] IPv6: ADDRCONF(NETDEV_UP): zdtmbr0: li
>
> All logs are here:
> https://s3.amazonaws.com/archive.travis-ci.org/jobs/211220073/log.txt


Could the attached patch fix this false alarm?

Thanks.

--001a11444a5ebf33b2054ad15daf
Content-Type: text/plain; charset=US-ASCII; name="br-lock-assert.diff"
Content-Disposition: attachment; filename="br-lock-assert.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j0bvykgn0

ZGlmZiAtLWdpdCBhL25ldC9icmlkZ2UvYnJfZmRiLmMgYi9uZXQvYnJpZGdlL2JyX2ZkYi5jCmlu
ZGV4IDRmNTk4ZGMuLmFiMDljM2MgMTAwNjQ0Ci0tLSBhL25ldC9icmlkZ2UvYnJfZmRiLmMKKysr
IGIvbmV0L2JyaWRnZS9icl9mZGIuYwpAQCAtMTA2LDcgKzEwNiw3IEBAIHN0YXRpYyBzdHJ1Y3Qg
bmV0X2JyaWRnZV9mZGJfZW50cnkgKmJyX2ZkYl9maW5kKHN0cnVjdCBuZXRfYnJpZGdlICpiciwK
IAlzdHJ1Y3QgaGxpc3RfaGVhZCAqaGVhZCA9ICZici0+aGFzaFticl9tYWNfaGFzaChhZGRyLCB2
aWQpXTsKIAlzdHJ1Y3QgbmV0X2JyaWRnZV9mZGJfZW50cnkgKmZkYjsKIAotCVdBUk5fT05fT05D
RSghYnJfaGFzaF9sb2NrX2hlbGQoYnIpKTsKKwlsb2NrZGVwX2Fzc2VydF9oZWxkKCZici0+aGFz
aF9sb2NrKTsKIAogCXJjdV9yZWFkX2xvY2soKTsKIAlmZGIgPSBmZGJfZmluZF9yY3UoaGVhZCwg
YWRkciwgdmlkKTsKZGlmZiAtLWdpdCBhL25ldC9icmlkZ2UvYnJfcHJpdmF0ZS5oIGIvbmV0L2Jy
aWRnZS9icl9wcml2YXRlLmgKaW5kZXggMjI4OGZjYS4uNjEzNjgxOCAxMDA2NDQKLS0tIGEvbmV0
L2JyaWRnZS9icl9wcml2YXRlLmgKKysrIGIvbmV0L2JyaWRnZS9icl9wcml2YXRlLmgKQEAgLTUz
MSwxNSArNTMxLDYgQEAgaW50IGJyX2ZkYl9leHRlcm5hbF9sZWFybl9hZGQoc3RydWN0IG5ldF9i
cmlkZ2UgKmJyLCBzdHJ1Y3QgbmV0X2JyaWRnZV9wb3J0ICpwLAogaW50IGJyX2ZkYl9leHRlcm5h
bF9sZWFybl9kZWwoc3RydWN0IG5ldF9icmlkZ2UgKmJyLCBzdHJ1Y3QgbmV0X2JyaWRnZV9wb3J0
ICpwLAogCQkJICAgICAgY29uc3QgdW5zaWduZWQgY2hhciAqYWRkciwgdTE2IHZpZCk7CiAKLXN0
YXRpYyBpbmxpbmUgYm9vbCBicl9oYXNoX2xvY2tfaGVsZChzdHJ1Y3QgbmV0X2JyaWRnZSAqYnIp
Ci17Ci0jaWZkZWYgQ09ORklHX0xPQ0tERVAKLQlyZXR1cm4gbG9ja2RlcF9pc19oZWxkKCZici0+
aGFzaF9sb2NrKTsKLSNlbHNlCi0JcmV0dXJuIHRydWU7Ci0jZW5kaWYKLX0KLQogLyogYnJfZm9y
d2FyZC5jICovCiBlbnVtIGJyX3BrdF90eXBlIHsKIAlCUl9QS1RfVU5JQ0FTVCwK
--001a11444a5ebf33b2054ad15daf--
