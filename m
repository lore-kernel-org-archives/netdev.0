From: TB <lkml@techboom.com>
Subject: Re: kernel BUG at net/ipv4/tcp_output.c:1006!
Date: Fri, 13 May 2011 15:30:08 -0400
Message-ID: <4DCD86C0.9030904@techboom.com>
References: <4DCD6658.3020901@techboom.com> <1305307633.3866.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305307633.3866.61.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-05-13 01:27 PM, Eric Dumazet wrote:
> Le vendredi 13 mai 2011 =C3=A0 13:11 -0400, TB a =C3=A9crit :
>> This is the 2.6.38.5 kernel with the patch in
>> [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide error
>>
>=20
> Please send us full disassembly of tcp_fragment (from vmlinux file)


GCC is debian 4.3.2-1.1
AS 2.18.0.20080103

CPU is Intel Xeon E5620
Kernel CPU is set to MCORE2 (Core 2/newer Xeon)


ffffffff814e7eb0 <tcp_fragment>:
ffffffff814e7eb0:       41 57                   push   %r15
ffffffff814e7eb2:       49 89 ff                mov    %rdi,%r15
ffffffff814e7eb5:       41 56                   push   %r14
ffffffff814e7eb7:       41 55                   push   %r13
ffffffff814e7eb9:       41 89 d5                mov    %edx,%r13d
ffffffff814e7ebc:       41 54                   push   %r12
ffffffff814e7ebe:       55                      push   %rbp
ffffffff814e7ebf:       53                      push   %rbx
ffffffff814e7ec0:       48 89 f3                mov    %rsi,%rbx
ffffffff814e7ec3:       48 83 ec 18             sub    $0x18,%rsp
ffffffff814e7ec7:       89 4c 24 0c             mov    %ecx,0xc(%rsp)
ffffffff814e7ecb:       8b 6e 68                mov    0x68(%rsi),%ebp
ffffffff814e7ece:       39 ea                   cmp    %ebp,%edx
ffffffff814e7ed0:       76 04                   jbe    ffffffff814e7ed6
<tcp_fragment+0x26>
ffffffff814e7ed2:       0f 0b                   ud2a
ffffffff814e7ed4:       eb fe                   jmp    ffffffff814e7ed4
<tcp_fragment+0x24>
ffffffff814e7ed6:       44 8b 66 6c             mov    0x6c(%rsi),%r12d
ffffffff814e7eda:       f6 46 7c 02             testb  $0x2,0x7c(%rsi)
ffffffff814e7ede:       74 33                   je     ffffffff814e7f13
<tcp_fragment+0x63>
ffffffff814e7ee0:       8b 86 b4 00 00 00       mov    0xb4(%rsi),%eax
ffffffff814e7ee6:       48 03 86 b8 00 00 00    add    0xb8(%rsi),%rax
ffffffff814e7eed:       8b 40 28                mov    0x28(%rax),%eax
ffffffff814e7ef0:       66 ff c8                dec    %ax
ffffffff814e7ef3:       74 1e                   je     ffffffff814e7f13
<tcp_fragment+0x63>
ffffffff814e7ef5:       45 85 e4                test   %r12d,%r12d
ffffffff814e7ef8:       74 19                   je     ffffffff814e7f13
<tcp_fragment+0x63>
ffffffff814e7efa:       31 d2                   xor    %edx,%edx
ffffffff814e7efc:       31 f6                   xor    %esi,%esi
ffffffff814e7efe:       b9 20 00 00 00          mov    $0x20,%ecx
ffffffff814e7f03:       48 89 df                mov    %rbx,%rdi
ffffffff814e7f06:       e8 68 fe fb ff          callq  ffffffff814a7d73
<pskb_expand_head>
ffffffff814e7f0b:       85 c0                   test   %eax,%eax
ffffffff814e7f0d:       0f 85 23 02 00 00       jne    ffffffff814e8136
<tcp_fragment+0x286>
ffffffff814e7f13:       44 29 e5                sub    %r12d,%ebp
ffffffff814e7f16:       45 31 f6                xor    %r14d,%r14d
ffffffff814e7f19:       89 e8                   mov    %ebp,%eax
ffffffff814e7f1b:       ba 20 00 00 00          mov    $0x20,%edx
ffffffff814e7f20:       44 29 e8                sub    %r13d,%eax
ffffffff814e7f23:       4c 89 ff                mov    %r15,%rdi
ffffffff814e7f26:       44 0f 49 f0             cmovns %eax,%r14d
ffffffff814e7f2a:       44 89 f6                mov    %r14d,%esi
ffffffff814e7f2d:       e8 82 51 ff ff          callq  ffffffff814dd0b4
<sk_stream_alloc_skb>
ffffffff814e7f32:       48 89 c5                mov    %rax,%rbp
ffffffff814e7f35:       48 85 c0                test   %rax,%rax
ffffffff814e7f38:       0f 84 f8 01 00 00       je     ffffffff814e8136
<tcp_fragment+0x286>
ffffffff814e7f3e:       8b 80 c8 00 00 00       mov    0xc8(%rax),%eax
ffffffff814e7f44:       41 01 87 1c 01 00 00    add    %eax,0x11c(%r15)
ffffffff814e7f4b:       49 8b 47 28             mov    0x28(%r15),%rax
ffffffff814e7f4f:       8b 95 c8 00 00 00       mov    0xc8(%rbp),%edx
ffffffff814e7f55:       48 83 b8 c8 00 00 00    cmpq   $0x0,0xc8(%rax)
ffffffff814e7f5c:       00
ffffffff814e7f5d:       74 07                   je     ffffffff814e7f66
<tcp_fragment+0xb6>
ffffffff814e7f5f:       41 29 97 98 00 00 00    sub    %edx,0x98(%r15)
ffffffff814e7f66:       8b 43 68                mov    0x68(%rbx),%eax
ffffffff814e7f69:       4c 8d 63 28             lea    0x28(%rbx),%r12
ffffffff814e7f6d:       44 29 e8                sub    %r13d,%eax
ffffffff814e7f70:       44 89 ea                mov    %r13d,%edx
ffffffff814e7f73:       44 29 f0                sub    %r14d,%eax
ffffffff814e7f76:       01 85 c8 00 00 00       add    %eax,0xc8(%rbp)
ffffffff814e7f7c:       29 83 c8 00 00 00       sub    %eax,0xc8(%rbx)
ffffffff814e7f82:       48 8d 45 28             lea    0x28(%rbp),%rax
ffffffff814e7f86:       48 89 44 24 10          mov    %rax,0x10(%rsp)
ffffffff814e7f8b:       41 03 54 24 10          add    0x10(%r12),%edx
ffffffff814e7f90:       89 50 10                mov    %edx,0x10(%rax)
ffffffff814e7f93:       41 8b 44 24 14          mov    0x14(%r12),%eax
ffffffff814e7f98:       48 8b 4c 24 10          mov    0x10(%rsp),%rcx
ffffffff814e7f9d:       89 41 14                mov    %eax,0x14(%rcx)
ffffffff814e7fa0:       41 89 54 24 14          mov    %edx,0x14(%r12)
ffffffff814e7fa5:       41 8a 54 24 1c          mov    0x1c(%r12),%dl
ffffffff814e7faa:       88 d0                   mov    %dl,%al
ffffffff814e7fac:       83 e0 f6                and
$0xfffffffffffffff6,%eax
ffffffff814e7faf:       41 88 44 24 1c          mov    %al,0x1c(%r12)
ffffffff814e7fb4:       88 51 1c                mov    %dl,0x1c(%rcx)
ffffffff814e7fb7:       41 8a 44 24 1d          mov    0x1d(%r12),%al
ffffffff814e7fbc:       88 41 1d                mov    %al,0x1d(%rcx)
ffffffff814e7fbf:       8b 93 b4 00 00 00       mov    0xb4(%rbx),%edx
ffffffff814e7fc5:       48 8b 83 b8 00 00 00    mov    0xb8(%rbx),%rax
ffffffff814e7fcc:       66 83 3c 10 00          cmpw   $0x0,(%rax,%rdx,=
1)
ffffffff814e7fd1:       75 6e                   jne    ffffffff814e8041
<tcp_fragment+0x191>
ffffffff814e7fd3:       8a 43 7c                mov    0x7c(%rbx),%al
ffffffff814e7fd6:       83 e0 0c                and    $0xc,%eax
ffffffff814e7fd9:       3c 0c                   cmp    $0xc,%al
ffffffff814e7fdb:       74 64                   je     ffffffff814e8041
<tcp_fragment+0x191>
ffffffff814e7fdd:       44 89 f6                mov    %r14d,%esi
ffffffff814e7fe0:       48 89 ef                mov    %rbp,%rdi
ffffffff814e7fe3:       e8 da f7 fb ff          callq  ffffffff814a77c2
<skb_put>
ffffffff814e7fe8:       31 c9                   xor    %ecx,%ecx
ffffffff814e7fea:       48 89 c6                mov    %rax,%rsi
ffffffff814e7fed:       44 89 ef                mov    %r13d,%edi
ffffffff814e7ff0:       44 89 f2                mov    %r14d,%edx
ffffffff814e7ff3:       48 03 bb c0 00 00 00    add    0xc0(%rbx),%rdi
ffffffff814e7ffa:       e8 91 4f 05 00          callq  ffffffff8153cf90
<csum_partial_copy_nocheck>
ffffffff814e7fff:       44 89 ee                mov    %r13d,%esi
ffffffff814e8002:       89 45 74                mov    %eax,0x74(%rbp)
ffffffff814e8005:       48 89 df                mov    %rbx,%rdi
ffffffff814e8008:       e8 09 de fb ff          callq  ffffffff814a5e16
<skb_trim>
ffffffff814e800d:       8b 45 74                mov    0x74(%rbp),%eax
ffffffff814e8010:       8b 4b 74                mov    0x74(%rbx),%ecx
ffffffff814e8013:       41 80 e5 01             and    $0x1,%r13b
ffffffff814e8017:       74 15                   je     ffffffff814e802e
<tcp_fragment+0x17e>
ffffffff814e8019:       89 c2                   mov    %eax,%edx
ffffffff814e801b:       c1 e8 08                shr    $0x8,%eax
ffffffff814e801e:       81 e2 ff 00 ff 00       and    $0xff00ff,%edx
ffffffff814e8024:       25 ff 00 ff 00          and    $0xff00ff,%eax
ffffffff814e8029:       c1 e2 08                shl    $0x8,%edx
ffffffff814e802c:       01 d0                   add    %edx,%eax
ffffffff814e802e:       f7 d0                   not    %eax
ffffffff814e8030:       89 c2                   mov    %eax,%edx
ffffffff814e8032:       01 ca                   add    %ecx,%edx
ffffffff814e8034:       0f 92 c0                setb   %al
ffffffff814e8037:       0f b6 c0                movzbl %al,%eax
ffffffff814e803a:       01 d0                   add    %edx,%eax
ffffffff814e803c:       89 43 74                mov    %eax,0x74(%rbx)
ffffffff814e803f:       eb 12                   jmp    ffffffff814e8053
<tcp_fragment+0x1a3>
ffffffff814e8041:       80 4b 7c 0c             orb    $0xc,0x7c(%rbx)
ffffffff814e8045:       44 89 ea                mov    %r13d,%edx
ffffffff814e8048:       48 89 ee                mov    %rbp,%rsi
ffffffff814e804b:       48 89 df                mov    %rbx,%rdi
ffffffff814e804e:       e8 f8 f7 fb ff          callq  ffffffff814a784b
<skb_split>
ffffffff814e8053:       8a 53 7c                mov    0x7c(%rbx),%dl
ffffffff814e8056:       8a 45 7c                mov    0x7c(%rbp),%al
ffffffff814e8059:       83 e2 0c                and    $0xc,%edx
ffffffff814e805c:       83 e0 f3                and
$0xfffffffffffffff3,%eax
ffffffff814e805f:       48 89 de                mov    %rbx,%rsi
ffffffff814e8062:       09 d0                   or     %edx,%eax
ffffffff814e8064:       4c 89 ff                mov    %r15,%rdi
ffffffff814e8067:       88 45 7c                mov    %al,0x7c(%rbp)
ffffffff814e806a:       41 8b 44 24 18          mov    0x18(%r12),%eax
ffffffff814e806f:       48 8b 54 24 10          mov    0x10(%rsp),%rdx
ffffffff814e8074:       89 42 18                mov    %eax,0x18(%rdx)
ffffffff814e8077:       48 8b 43 10             mov    0x10(%rbx),%rax
ffffffff814e807b:       8b 93 b4 00 00 00       mov    0xb4(%rbx),%edx
ffffffff814e8081:       48 89 45 10             mov    %rax,0x10(%rbp)
ffffffff814e8085:       48 8b 83 b8 00 00 00    mov    0xb8(%rbx),%rax
ffffffff814e808c:       44 8b 64 10 04          mov
0x4(%rax,%rdx,1),%r12d
ffffffff814e8091:       8b 54 24 0c             mov    0xc(%rsp),%edx
ffffffff814e8095:       e8 3d dd ff ff          callq  ffffffff814e5dd7
<tcp_set_skb_tso_segs>
ffffffff814e809a:       8b 54 24 0c             mov    0xc(%rsp),%edx
ffffffff814e809e:       48 89 ee                mov    %rbp,%rsi
ffffffff814e80a1:       4c 89 ff                mov    %r15,%rdi
ffffffff814e80a4:       e8 2e dd ff ff          callq  ffffffff814e5dd7
<tcp_set_skb_tso_segs>
ffffffff814e80a9:       48 8b 4c 24 10          mov    0x10(%rsp),%rcx
ffffffff814e80ae:       8b 49 14                mov    0x14(%rcx),%ecx
ffffffff814e80b1:       41 39 8f 1c 04 00 00    cmp    %ecx,0x41c(%r15)
ffffffff814e80b8:       78 39                   js     ffffffff814e80f3
<tcp_fragment+0x243>
ffffffff814e80ba:       8b 8b b4 00 00 00       mov    0xb4(%rbx),%ecx
ffffffff814e80c0:       41 0f b7 d4             movzwl %r12w,%edx
ffffffff814e80c4:       48 8b 83 b8 00 00 00    mov    0xb8(%rbx),%rax
ffffffff814e80cb:       0f b7 44 08 04          movzwl 0x4(%rax,%rcx,1)=
,%eax
ffffffff814e80d0:       8b 8d b4 00 00 00       mov    0xb4(%rbp),%ecx
ffffffff814e80d6:       29 c2                   sub    %eax,%edx
ffffffff814e80d8:       48 8b 85 b8 00 00 00    mov    0xb8(%rbp),%rax
ffffffff814e80df:       0f b7 44 08 04          movzwl 0x4(%rax,%rcx,1)=
,%eax
ffffffff814e80e4:       29 c2                   sub    %eax,%edx
ffffffff814e80e6:       74 0b                   je     ffffffff814e80f3
<tcp_fragment+0x243>
ffffffff814e80e8:       48 89 de                mov    %rbx,%rsi
ffffffff814e80eb:       4c 89 ff                mov    %r15,%rdi
ffffffff814e80ee:       e8 1a f4 ff ff          callq  ffffffff814e750d
<tcp_adjust_pcount>
ffffffff814e80f3:       8a 45 7c                mov    0x7c(%rbp),%al
ffffffff814e80f6:       a8 10                   test   $0x10,%al
ffffffff814e80f8:       74 04                   je     ffffffff814e80fe
<tcp_fragment+0x24e>
ffffffff814e80fa:       0f 0b                   ud2a
ffffffff814e80fc:       eb fe                   jmp    ffffffff814e80fc
<tcp_fragment+0x24c>
ffffffff814e80fe:       83 c8 10                or     $0x10,%eax
ffffffff814e8101:       88 45 7c                mov    %al,0x7c(%rbp)
ffffffff814e8104:       8b 85 b4 00 00 00       mov    0xb4(%rbp),%eax
ffffffff814e810a:       48 03 85 b8 00 00 00    add    0xb8(%rbp),%rax
ffffffff814e8111:       f0 81 40 28 00 00 01    lock addl
$0x10000,0x28(%rax)
ffffffff814e8118:       00
ffffffff814e8119:       48 8b 03                mov    (%rbx),%rax
ffffffff814e811c:       48 89 5d 08             mov    %rbx,0x8(%rbp)
ffffffff814e8120:       48 89 45 00             mov    %rax,0x0(%rbp)
ffffffff814e8124:       48 89 68 08             mov    %rbp,0x8(%rax)
ffffffff814e8128:       48 89 2b                mov    %rbp,(%rbx)
ffffffff814e812b:       31 c0                   xor    %eax,%eax
ffffffff814e812d:       41 ff 87 10 01 00 00    incl   0x110(%r15)
ffffffff814e8134:       eb 05                   jmp    ffffffff814e813b
<tcp_fragment+0x28b>
ffffffff814e8136:       b8 f4 ff ff ff          mov    $0xfffffff4,%eax
ffffffff814e813b:       48 83 c4 18             add    $0x18,%rsp
ffffffff814e813f:       5b                      pop    %rbx
ffffffff814e8140:       5d                      pop    %rbp
ffffffff814e8141:       41 5c                   pop    %r12
ffffffff814e8143:       41 5d                   pop    %r13
ffffffff814e8145:       41 5e                   pop    %r14
ffffffff814e8147:       41 5f                   pop    %r15
ffffffff814e8149:       c3                      retq
