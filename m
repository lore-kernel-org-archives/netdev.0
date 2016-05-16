From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [v4.6-rc7-183-g1410b74e4061]
Date: Mon, 16 May 2016 20:11:51 +0200
Message-ID: <CA+icZUVAwmEzexnq=nNNMjVVdhq3fE_d4JoEt6Gz4bbdmgbnqA@mail.gmail.com>
References: <CA+icZUXF9DkymNNGwP8zzmKY9PRAPGFZ+7p9En1xy80FcX_RRw@mail.gmail.com>
	<20160516105045.GA19189@gmail.com>
	<CA+icZUUJed6KqxhPKyrr_ACCfnp09T+R5S0J8-Bf6+1SJZvtoQ@mail.gmail.com>
	<20160516175735.GS3193@twins.programming.kicks-ass.net>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114809fa0b479d0532f98f6b
Cc: Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160516175735.GS3193@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a114809fa0b479d0532f98f6b
Content-Type: text/plain; charset=UTF-8

On 5/16/16, Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, May 16, 2016 at 07:42:35PM +0200, Sedat Dilek wrote:
>
>> Unfortunately, I could not reproduce this again with none of my
>> 183-kernels.
>> When I first hit a "chain_key collision" issue, it was hard to redproduce,
>> so.
>> Any idea, how I can "force" this?
>
> Nope; I wish I knew, that'd be so much easier to work with :/
>
> I'm hoping someone will report a reproducer, even something that
> triggers once every 5-10 runs would be awesome.
>
> In any case, like I've explained before, nothing regressed as such, we
> only added this new warning under DEBUG_LOCKDEP because we want to
> better understand the condition that triggers it.
>
> If it bothers you, just turn off DEBUG_LOCKDEP and know that your kernel
> is as reliable as it was before. OTOH, if you do keep it on, please
> let me know if you can (semi) reliably trigger this, as I'd really like
> to have a better understanding.
>

OK, I keep checking my logs.

I refreshed your patch Ingo pointed me to.

But it fails like this (on top of Linux v4.6 final)...
[...]
  if [ "" = "-pg" ]; then if [ kernel/locking/mutex-debug.o !=
"scripts/mod/empty.o" ]; then ./scripts/recordmcount
"kernel/locking/mutex-debug.o"; fi; fi;
  mycompiler -Wp,-MD,kernel/locking/.lockdep.o.d  -nostdinc -isystem
/usr/lib/gcc/x86_64-linux-gnu/4.9/include -nostdinc -isystem
/usr/lib/gcc/x86_64-linux-gnu/4.9/include -I./arch/x86/include
-Iarch/x86/include/generated/uapi -Iarch/x86/include/generated
-Iinclude -I./arch/x86/include/uapi -Iarch/x86/include/generated/uapi
-I./include/uapi -Iinclude/generated/uapi -include
./include/linux/kconfig.h -D__KERNEL__ -Wall -Wundef
-Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common
-Werror-implicit-function-declaration -Wno-format-security -std=gnu89
-mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -m64 -falign-jumps=1
-falign-loops=1 -mno-80387 -mno-fp-ret-in-387
-mpreferred-stack-boundary=3 -mtune=generic -mno-red-zone
-mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args
-DCONFIG_X86_X32_ABI -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1
-DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_SSSE3=1
-DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -DCONFIG_AS_AVX2=1 -pipe
-Wno-sign-compare -fno-asynchronous-unwind-tables
-fno-delete-null-pointer-checks -O2 --param=allow-store-data-races=0
-Wframe-larger-than=1024 -fno-stack-protector
-Wno-unused-but-set-variable -fno-omit-frame-pointer
-fno-optimize-sibling-calls -fno-var-tracking-assignments -mfentry
-DCC_USING_FENTRY -Wdeclaration-after-statement -Wno-pointer-sign
-fno-strict-overflow -fconserve-stack -Werror=implicit-int
-Werror=strict-prototypes -Werror=date-time -DCC_HAVE_ASM_GOTO
-D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(lockdep)"
-D"KBUILD_MODNAME=KBUILD_STR(lockdep)" -c -o
kernel/locking/.tmp_lockdep.o kernel/locking/lockdep.c
kernel/locking/lockdep.c: In function 'print_chain_keys_held_locks':
kernel/locking/lockdep.c:2034:2: error: too few arguments to function
'print_chain_key_iteration'
  print_chain_key_iteration(hlock_next->class_idx, chain_key);
  ^
kernel/locking/lockdep.c:2006:12: note: declared here
 static u64 print_chain_key_iteration(int class_idx, u64 chain_key,
u64 prev_key)
            ^
make[4]: *** [kernel/locking/lockdep.o] Error 1
make[3]: *** [kernel/locking] Error 2
make[2]: *** [kernel] Error 2
[...]

- Sedat -

--001a114809fa0b479d0532f98f6b
Content-Type: text/x-diff; charset=US-ASCII;
	name="0001-locking-lockdep-Some-more-additional-chain_key-colli.patch"
Content-Disposition: attachment;
	filename="0001-locking-lockdep-Some-more-additional-chain_key-colli.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: file1

RnJvbSBiOTUzYmUyNTViZmI0Njk3MGM3NTk1MGUyOTdiZTgzNjU3N2JjNTI1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBNb24sIDE2IE1heSAyMDE2IDE1OjUxOjA0ICswMjAwClN1YmplY3Q6IFtQQVRDSF0gbG9j
a2luZy9sb2NrZGVwOiBTb21lIG1vcmUgYWRkaXRpb25hbCBjaGFpbl9rZXkgY29sbGlzaW9uCiBp
bmZvcm1hdGlvbgoKRnJvbTogUGV0ZXIgWmlqbHN0cmEgPHBldGVyekBpbmZyYWRlYWQub3JnPgoK
Rm9yIG1vcmUgZGV0YWlscyBzZWUgdGhyZWFkICJbdjQuNi1yYzctMTgzLWcxNDEwYjc0ZTQwNjFd
IiBhdCBMS01MIFsxXS4KClBhdGNoIGZvciB0ZXN0aW5nIGZyb20gUGV0ZXIgWmlqbHN0cmEgc2Vl
IFsyXSBhbmQgWzNdLgoKWzFdIGh0dHA6Ly9tYXJjLmluZm8vP3Q9MTQ2MzIxNzg0MzAwMDAyJnI9
MSZ3PTIKWzJdIGh0dHA6Ly9tYXJjLmluZm8vP2w9bGludXgta2VybmVsJm09MTQ2MzM5NTg3NTA2
MTEwJnc9MgpbM10gaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTYvNS8xMC8yMTQKCkNjOiBXYW5w
ZW5nIExpIDx3YW5wZW5nLmxpQGxpbnV4LmludGVsLmNvbT4KQ2M6IEFsZnJlZG8gQWx2YXJleiBG
ZXJuYW5kZXogPGFsZnJlZG9hbHZhcmV6ZmVybmFuZGV6QGdtYWlsLmNvbT4KQ2M6IFBldGVyIFpp
amxzdHJhIChJbnRlbCkgPHBldGVyekBpbmZyYWRlYWQub3JnPgpDYzogTGludXMgVG9ydmFsZHMg
PHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3JnPgpDYzogVGhvbWFzIEdsZWl4bmVyIDx0Z2x4
QGxpbnV0cm9uaXguZGU+CkNjOiBJbmdvIE1vbG5hciA8bWluZ29Aa2VybmVsLm9yZz4KQ2M6IFNl
ZGF0IERpbGVrIDxzZWRhdC5kaWxla0BnbWFpbC5jb20+CkNjOiBUZWQgVHNvIDx0eXRzb0BtaXQu
ZWR1PgpDYzogTEtNTCA8bGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZz4KQ2M6IHRoZSBhcmNo
L3g4NiBtYWludGFpbmVycyA8eDg2QGtlcm5lbC5vcmc+CkNjOiBsaW51eC1mc2RldmVsQHZnZXIu
a2VybmVsLm9yZwotLS0KIGtlcm5lbC9sb2NraW5nL2xvY2tkZXAuYyB8IDMxICsrKysrKysrKysr
KysrKysrKystLS0tLS0tLS0tLS0KIDEgZmlsZSBjaGFuZ2VkLCAxOSBpbnNlcnRpb25zKCspLCAx
MiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9rZXJuZWwvbG9ja2luZy9sb2NrZGVwLmMgYi9r
ZXJuZWwvbG9ja2luZy9sb2NrZGVwLmMKaW5kZXggNzhjMWMwZWU2ZGMxLi41ZGMyMWViMTAxYjAg
MTAwNjQ0Ci0tLSBhL2tlcm5lbC9sb2NraW5nL2xvY2tkZXAuYworKysgYi9rZXJuZWwvbG9ja2lu
Zy9sb2NrZGVwLmMKQEAgLTIwMDMsMTMgKzIwMDMsMTQgQEAgc3RhdGljIGlubGluZSBpbnQgZ2V0
X2ZpcnN0X2hlbGRfbG9jayhzdHJ1Y3QgdGFza19zdHJ1Y3QgKmN1cnIsCiAvKgogICogUmV0dXJu
cyB0aGUgbmV4dCBjaGFpbl9rZXkgaXRlcmF0aW9uCiAgKi8KLXN0YXRpYyB1NjQgcHJpbnRfY2hh
aW5fa2V5X2l0ZXJhdGlvbihpbnQgY2xhc3NfaWR4LCB1NjQgY2hhaW5fa2V5KQorc3RhdGljIHU2
NCBwcmludF9jaGFpbl9rZXlfaXRlcmF0aW9uKGludCBjbGFzc19pZHgsIHU2NCBjaGFpbl9rZXks
IHU2NCBwcmV2X2tleSkKIHsKIAl1NjQgbmV3X2NoYWluX2tleSA9IGl0ZXJhdGVfY2hhaW5fa2V5
KGNoYWluX2tleSwgY2xhc3NfaWR4KTsKIAotCXByaW50aygiIGNsYXNzX2lkeDolZCAtPiBjaGFp
bl9rZXk6JTAxNkx4IiwKKwlwcmludGsoIiBjbGFzc19pZHg6ICVkIC0+IGNoYWluX2tleTogJTAx
Nkx4ICglMDE2THgpIiwKIAkJY2xhc3NfaWR4LAotCQkodW5zaWduZWQgbG9uZyBsb25nKW5ld19j
aGFpbl9rZXkpOworCQkodW5zaWduZWQgbG9uZyBsb25nKW5ld19jaGFpbl9rZXksCisJCSh1bnNp
Z25lZCBsb25nIGxvbmcpcHJldl9rZXkpOwogCXJldHVybiBuZXdfY2hhaW5fa2V5OwogfQogCkBA
IC0yMDI0LDcgKzIwMjUsOCBAQCBwcmludF9jaGFpbl9rZXlzX2hlbGRfbG9ja3Moc3RydWN0IHRh
c2tfc3RydWN0ICpjdXJyLCBzdHJ1Y3QgaGVsZF9sb2NrICpobG9ja19uZQogCXByaW50aygiZGVw
dGg6ICV1XG4iLCBkZXB0aCArIDEpOwogCWZvciAoaSA9IGdldF9maXJzdF9oZWxkX2xvY2soY3Vy
ciwgaGxvY2tfbmV4dCk7IGkgPCBkZXB0aDsgaSsrKSB7CiAJCWhsb2NrID0gY3Vyci0+aGVsZF9s
b2NrcyArIGk7Ci0JCWNoYWluX2tleSA9IHByaW50X2NoYWluX2tleV9pdGVyYXRpb24oaGxvY2st
PmNsYXNzX2lkeCwgY2hhaW5fa2V5KTsKKwkJY2hhaW5fa2V5ID0gcHJpbnRfY2hhaW5fa2V5X2l0
ZXJhdGlvbihobG9jay0+Y2xhc3NfaWR4LCBjaGFpbl9rZXksCisJCQkJCQkgICAgICBobG9jay0+
cHJldl9jaGFpbl9rZXkpOwogCiAJCXByaW50X2xvY2soaGxvY2spOwogCX0KQEAgLTIwNDIsNyAr
MjA0NCw3IEBAIHN0YXRpYyB2b2lkIHByaW50X2NoYWluX2tleXNfY2hhaW4oc3RydWN0IGxvY2tf
Y2hhaW4gKmNoYWluKQogCXByaW50aygiZGVwdGg6ICV1XG4iLCBjaGFpbi0+ZGVwdGgpOwogCWZv
ciAoaSA9IDA7IGkgPCBjaGFpbi0+ZGVwdGg7IGkrKykgewogCQljbGFzc19pZCA9IGNoYWluX2hs
b2Nrc1tjaGFpbi0+YmFzZSArIGldOwotCQljaGFpbl9rZXkgPSBwcmludF9jaGFpbl9rZXlfaXRl
cmF0aW9uKGNsYXNzX2lkICsgMSwgY2hhaW5fa2V5KTsKKwkJY2hhaW5fa2V5ID0gcHJpbnRfY2hh
aW5fa2V5X2l0ZXJhdGlvbihjbGFzc19pZCArIDEsIGNoYWluX2tleSwgMCk7CiAKIAkJcHJpbnRf
bG9ja19uYW1lKGxvY2tfY2xhc3NlcyArIGNsYXNzX2lkKTsKIAkJcHJpbnRrKCJcbiIpOwpAQCAt
MjA1MSw3ICsyMDUzLDggQEAgc3RhdGljIHZvaWQgcHJpbnRfY2hhaW5fa2V5c19jaGFpbihzdHJ1
Y3QgbG9ja19jaGFpbiAqY2hhaW4pCiAKIHN0YXRpYyB2b2lkIHByaW50X2NvbGxpc2lvbihzdHJ1
Y3QgdGFza19zdHJ1Y3QgKmN1cnIsCiAJCQlzdHJ1Y3QgaGVsZF9sb2NrICpobG9ja19uZXh0LAot
CQkJc3RydWN0IGxvY2tfY2hhaW4gKmNoYWluKQorCQkJc3RydWN0IGxvY2tfY2hhaW4gKmNoYWlu
LAorCQkJdTY0IGNoYWluX2tleSkKIHsKIAlwcmludGsoIlxuIik7CiAJcHJpbnRrKCI9PT09PT09
PT09PT09PT09PT09PT09XG4iKTsKQEAgLTIwNjAsMTEgKzIwNjMsMTQgQEAgc3RhdGljIHZvaWQg
cHJpbnRfY29sbGlzaW9uKHN0cnVjdCB0YXNrX3N0cnVjdCAqY3VyciwKIAlwcmludGsoIi0tLS0t
LS0tLS0tLS0tLS0tLS0tLS1cbiIpOwogCXByaW50aygiJXMvJWQ6ICIsIGN1cnJlbnQtPmNvbW0s
IHRhc2tfcGlkX25yKGN1cnJlbnQpKTsKIAlwcmludGsoIkhhc2ggY2hhaW4gYWxyZWFkeSBjYWNo
ZWQgYnV0IHRoZSBjb250ZW50cyBkb24ndCBtYXRjaCFcbiIpOworCXByaW50aygiY2hhaW4tPmNo
YWluX2tleTogJTAxNkx4IGNoYWluX2tleTogJTAxNkx4XG4iLAorCQkJKHVuc2lnbmVkIGxvbmcg
bG9uZyljaGFpbi0+Y2hhaW5fa2V5LAorCQkJKHVuc2lnbmVkIGxvbmcgbG9uZyljaGFpbl9rZXkp
OwogCi0JcHJpbnRrKCJIZWxkIGxvY2tzOiIpOworCXByaW50aygiSGVsZCBsb2NrczogIik7CiAJ
cHJpbnRfY2hhaW5fa2V5c19oZWxkX2xvY2tzKGN1cnIsIGhsb2NrX25leHQpOwogCi0JcHJpbnRr
KCJMb2NrcyBpbiBjYWNoZWQgY2hhaW46Iik7CisJcHJpbnRrKCJMb2NrcyBpbiBjYWNoZWQgY2hh
aW46ICIpOwogCXByaW50X2NoYWluX2tleXNfY2hhaW4oY2hhaW4pOwogCiAJcHJpbnRrKCJcbnN0
YWNrIGJhY2t0cmFjZTpcbiIpOwpAQCAtMjA4MCw3ICsyMDg2LDggQEAgc3RhdGljIHZvaWQgcHJp
bnRfY29sbGlzaW9uKHN0cnVjdCB0YXNrX3N0cnVjdCAqY3VyciwKICAqLwogc3RhdGljIGludCBj
aGVja19ub19jb2xsaXNpb24oc3RydWN0IHRhc2tfc3RydWN0ICpjdXJyLAogCQkJc3RydWN0IGhl
bGRfbG9jayAqaGxvY2ssCi0JCQlzdHJ1Y3QgbG9ja19jaGFpbiAqY2hhaW4pCisJCQlzdHJ1Y3Qg
bG9ja19jaGFpbiAqY2hhaW4sCisJCQl1NjQgY2hhaW5fa2V5KQogewogI2lmZGVmIENPTkZJR19E
RUJVR19MT0NLREVQCiAJaW50IGksIGosIGlkOwpAQCAtMjA4OCw3ICsyMDk1LDcgQEAgc3RhdGlj
IGludCBjaGVja19ub19jb2xsaXNpb24oc3RydWN0IHRhc2tfc3RydWN0ICpjdXJyLAogCWkgPSBn
ZXRfZmlyc3RfaGVsZF9sb2NrKGN1cnIsIGhsb2NrKTsKIAogCWlmIChERUJVR19MT0NLU19XQVJO
X09OKGNoYWluLT5kZXB0aCAhPSBjdXJyLT5sb2NrZGVwX2RlcHRoIC0gKGkgLSAxKSkpIHsKLQkJ
cHJpbnRfY29sbGlzaW9uKGN1cnIsIGhsb2NrLCBjaGFpbik7CisJCXByaW50X2NvbGxpc2lvbihj
dXJyLCBobG9jaywgY2hhaW4sIGNoYWluX2tleSk7CiAJCXJldHVybiAwOwogCX0KIApAQCAtMjA5
Niw3ICsyMTAzLDcgQEAgc3RhdGljIGludCBjaGVja19ub19jb2xsaXNpb24oc3RydWN0IHRhc2tf
c3RydWN0ICpjdXJyLAogCQlpZCA9IGN1cnItPmhlbGRfbG9ja3NbaV0uY2xhc3NfaWR4IC0gMTsK
IAogCQlpZiAoREVCVUdfTE9DS1NfV0FSTl9PTihjaGFpbl9obG9ja3NbY2hhaW4tPmJhc2UgKyBq
XSAhPSBpZCkpIHsKLQkJCXByaW50X2NvbGxpc2lvbihjdXJyLCBobG9jaywgY2hhaW4pOworCQkJ
cHJpbnRfY29sbGlzaW9uKGN1cnIsIGhsb2NrLCBjaGFpbiwgY2hhaW5fa2V5KTsKIAkJCXJldHVy
biAwOwogCQl9CiAJfQpAQCAtMjEzNCw3ICsyMTQxLDcgQEAgc3RhdGljIGlubGluZSBpbnQgbG9v
a3VwX2NoYWluX2NhY2hlKHN0cnVjdCB0YXNrX3N0cnVjdCAqY3VyciwKIAkJaWYgKGNoYWluLT5j
aGFpbl9rZXkgPT0gY2hhaW5fa2V5KSB7CiBjYWNoZV9oaXQ6CiAJCQlkZWJ1Z19hdG9taWNfaW5j
KGNoYWluX2xvb2t1cF9oaXRzKTsKLQkJCWlmICghY2hlY2tfbm9fY29sbGlzaW9uKGN1cnIsIGhs
b2NrLCBjaGFpbikpCisJCQlpZiAoIWNoZWNrX25vX2NvbGxpc2lvbihjdXJyLCBobG9jaywgY2hh
aW4sIGNoYWluX2tleSkpCiAJCQkJcmV0dXJuIDA7CiAKIAkJCWlmICh2ZXJ5X3ZlcmJvc2UoY2xh
c3MpKQotLSAKMi44LjIKCg==
--001a114809fa0b479d0532f98f6b--
