From: Roel Kluin <12o3l@tiscali.nl>
Subject: Re: [BUG] in inet6_create
Date: Fri, 02 Nov 2007 18:51:08 +0100
Message-ID: <472B638C.1030001@tiscali.nl>
References: <472A3218.20708@tiscali.nl> <472A41AF.2030704@tiscali.nl> <472AEAB0.5090709@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:40563 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbXKBRvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 13:51:13 -0400
In-Reply-To: <472AEAB0.5090709@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Roel Kluin wrote:
>> Roel Kluin wrote:
>>> I got this bug recently, I am not sure whether this is related to any previously 
>>> reported ones. It was a recently pulled git kernel. Also I have been hacking my
>>> kernel a bit lately, but I think that I haven't got any changes in the currently
>>> running kernel.
>>>
>>> FYI: my network card was not running (module not loaded, and I just started 
>>> thunderbird)
>>>
>>> Roel
>>>
>>> More information needed?
> 
> Yes, please.
> 
> Can you send us the disasm (objdump -dr) of your ipv6 module. 
> More precisely - I need the disassembled inet6_create() function to
> figure out where exactly this thing happened.

I was very lucky to still be able to produce this: When the bug hit me, I had just
recompiled a new kernel, however, since I had previously git-pulled, (but not yet
compiled) the old module was not overwritten.

to answer the question in your other mail - whether I hacked this kernel - I am not
100% certain, I am certain, however that I did not touch IPv6 code, and my changes
to net code were very trivial oneliner changes that I have previously posted, and
were generally accepted as fixes.
--
000002f0 <inet6_create>:
     2f0:	55                   	push   %ebp
     2f1:	bd 9f ff ff ff       	mov    $0xffffff9f,%ebp
     2f6:	57                   	push   %edi
     2f7:	56                   	push   %esi
     2f8:	89 ce                	mov    %ecx,%esi
     2fa:	53                   	push   %ebx
     2fb:	83 ec 20             	sub    $0x20,%esp
     2fe:	3d 00 00 00 00       	cmp    $0x0,%eax
			2ff: R_386_32	init_net
     303:	89 54 24 10          	mov    %edx,0x10(%esp)
     307:	74 0a                	je     313 <inet6_create+0x23>
     309:	83 c4 20             	add    $0x20,%esp
     30c:	89 e8                	mov    %ebp,%eax
     30e:	5b                   	pop    %ebx
     30f:	5e                   	pop    %esi
     310:	5f                   	pop    %edi
     311:	5d                   	pop    %ebp
     312:	c3                   	ret    
     313:	8b 42 3c             	mov    0x3c(%edx),%eax
     316:	83 e8 02             	sub    $0x2,%eax
     319:	66 83 f8 01          	cmp    $0x1,%ax
     31d:	76 0e                	jbe    32d <inet6_create+0x3d>
     31f:	8b 0d 00 00 00 00    	mov    0x0,%ecx
			321: R_386_32	inet_ehash_secret
     325:	85 c9                	test   %ecx,%ecx
     327:	0f 84 76 02 00 00    	je     5a3 <inet6_create+0x2b3>
     32d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
     334:	00 
     335:	31 d2                	xor    %edx,%edx
     337:	31 c9                	xor    %ecx,%ecx
     339:	b8 00 00 00 00       	mov    $0x0,%eax
			33a: R_386_32	rcu_lock_map
     33e:	c7 44 24 08 35 03 00 	movl   $0x335,0x8(%esp)
     345:	00 
			342: R_386_32	.text
     346:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
     34d:	00 
     34e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     355:	e8 fc ff ff ff       	call   356 <inet6_create+0x66>
			356: R_386_PC32	lock_acquire
     35a:	8b 44 24 10          	mov    0x10(%esp),%eax
     35e:	8b 78 3c             	mov    0x3c(%eax),%edi
     361:	0f bf c7             	movswl %di,%eax
     364:	c1 e0 03             	shl    $0x3,%eax
     367:	8b 98 00 00 00 00    	mov    0x0(%eax),%ebx
			369: R_386_32	.bss
     36d:	8d 90 00 00 00 00    	lea    0x0(%eax),%edx
			36f: R_386_32	.bss
     373:	89 5c 24 1c          	mov    %ebx,0x1c(%esp)
     377:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     37b:	8b 00                	mov    (%eax),%eax
     37d:	8d 44 20 00          	lea    0x0(%eax),%eax
     381:	39 d3                	cmp    %edx,%ebx
     383:	bd a2 ff ff ff       	mov    $0xffffffa2,%ebp
     388:	75 3a                	jne    3c4 <inet6_create+0xd4>
     38a:	e9 23 02 00 00       	jmp    5b2 <inet6_create+0x2c2>
     38f:	90                   	nop    
     390:	85 f6                	test   %esi,%esi
     392:	0f 84 5d 02 00 00    	je     5f5 <inet6_create+0x305>
     398:	66 85 c0             	test   %ax,%ax
     39b:	90                   	nop    
     39c:	8d 74 26 00          	lea    0x0(%esi),%esi
     3a0:	74 31                	je     3d3 <inet6_create+0xe3>
     3a2:	8b 1b                	mov    (%ebx),%ebx
     3a4:	89 5c 24 1c          	mov    %ebx,0x1c(%esp)
     3a8:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     3ac:	8b 00                	mov    (%eax),%eax
     3ae:	8d 44 20 00          	lea    0x0(%eax),%eax
     3b2:	0f bf c7             	movswl %di,%eax
     3b5:	8d 04 c5 00 00 00 00 	lea    0x0(,%eax,8),%eax
			3b8: R_386_32	.bss
     3bc:	39 d8                	cmp    %ebx,%eax
     3be:	0f 84 e9 01 00 00    	je     5ad <inet6_create+0x2bd>
     3c4:	0f b7 43 0a          	movzwl 0xa(%ebx),%eax
     3c8:	0f b7 c8             	movzwl %ax,%ecx
     3cb:	39 ce                	cmp    %ecx,%esi
     3cd:	75 c1                	jne    390 <inet6_create+0xa0>
     3cf:	85 f6                	test   %esi,%esi
     3d1:	74 cf                	je     3a2 <inet6_create+0xb2>
     3d3:	8b 43 14             	mov    0x14(%ebx),%eax
     3d6:	85 c0                	test   %eax,%eax
     3d8:	7e 12                	jle    3ec <inet6_create+0xfc>
     3da:	e8 fc ff ff ff       	call   3db <inet6_create+0xeb>
			3db: R_386_PC32	capable
     3df:	85 c0                	test   %eax,%eax
     3e1:	bd ff ff ff ff       	mov    $0xffffffff,%ebp
     3e6:	0f 84 99 01 00 00    	je     585 <inet6_create+0x295>
     3ec:	8b 43 10             	mov    0x10(%ebx),%eax
     3ef:	8b 54 24 10          	mov    0x10(%esp),%edx
     3f3:	b9 ec 03 00 00       	mov    $0x3ec,%ecx
			3f4: R_386_32	.text
     3f8:	89 42 08             	mov    %eax,0x8(%edx)
     3fb:	0f b6 43 18          	movzbl 0x18(%ebx),%eax
     3ff:	8b 7b 0c             	mov    0xc(%ebx),%edi
     402:	88 44 24 17          	mov    %al,0x17(%esp)
     406:	0f b6 53 19          	movzbl 0x19(%ebx),%edx
     40a:	b8 00 00 00 00       	mov    $0x0,%eax
			40b: R_386_32	rcu_lock_map
     40f:	88 54 24 16          	mov    %dl,0x16(%esp)
     413:	ba 01 00 00 00       	mov    $0x1,%edx
     418:	e8 fc ff ff ff       	call   419 <inet6_create+0x129>
			419: R_386_PC32	lock_release
     41d:	8b 57 70             	mov    0x70(%edi),%edx
     420:	85 d2                	test   %edx,%edx
     422:	0f 84 36 02 00 00    	je     65e <inet6_create+0x36e>
     428:	b9 d0 00 00 00       	mov    $0xd0,%ecx
     42d:	ba 0a 00 00 00       	mov    $0xa,%edx
     432:	b8 00 00 00 00       	mov    $0x0,%eax
			433: R_386_32	init_net
     437:	89 3c 24             	mov    %edi,(%esp)
     43a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
     441:	00 
     442:	bd 97 ff ff ff       	mov    $0xffffff97,%ebp
     447:	e8 fc ff ff ff       	call   448 <inet6_create+0x158>
			448: R_386_PC32	sk_alloc
     44c:	85 c0                	test   %eax,%eax
     44e:	89 c7                	mov    %eax,%edi
     450:	0f 84 b3 fe ff ff    	je     309 <inet6_create+0x19>
     456:	89 c2                	mov    %eax,%edx
     458:	8b 44 24 10          	mov    0x10(%esp),%eax
     45c:	e8 fc ff ff ff       	call   45d <inet6_create+0x16d>
			45d: R_386_PC32	sock_init_data
     461:	80 64 24 17 03       	andb   $0x3,0x17(%esp)
     466:	0f b6 54 24 17       	movzbl 0x17(%esp),%edx
     46b:	0f b6 47 28          	movzbl 0x28(%edi),%eax
     46f:	c1 e2 02             	shl    $0x2,%edx
     472:	83 e0 f3             	and    $0xfffffff3,%eax
     475:	09 d0                	or     %edx,%eax
     477:	88 47 28             	mov    %al,0x28(%edi)
     47a:	0f b6 44 24 16       	movzbl 0x16(%esp),%eax
     47f:	a8 01                	test   $0x1,%al
     481:	74 04                	je     487 <inet6_create+0x197>
     483:	c6 47 03 01          	movb   $0x1,0x3(%edi)
     487:	0f b6 97 3f 02 00 00 	movzbl 0x23f(%edi),%edx
     48e:	c1 e8 02             	shr    $0x2,%eax
     491:	83 e0 01             	and    $0x1,%eax
     494:	01 c0                	add    %eax,%eax
     496:	83 e2 fd             	and    $0xfffffffd,%edx
     499:	09 c2                	or     %eax,%edx
     49b:	88 97 3f 02 00 00    	mov    %dl,0x23f(%edi)
     4a1:	8b 44 24 10          	mov    0x10(%esp),%eax
     4a5:	66 83 78 3c 03       	cmpw   $0x3,0x3c(%eax)
     4aa:	0f 84 64 01 00 00    	je     614 <inet6_create+0x324>
     4b0:	89 f2                	mov    %esi,%edx
     4b2:	c7 87 18 02 00 00 00 	movl   $0x0,0x218(%edi)
     4b9:	00 00 00 
			4b8: R_386_32	inet_sock_destruct
     4bc:	66 c7 07 0a 00       	movw   $0xa,(%edi)
     4c1:	88 57 29             	mov    %dl,0x29(%edi)
     4c4:	8b 43 0c             	mov    0xc(%ebx),%eax
     4c7:	8b 40 40             	mov    0x40(%eax),%eax
     4ca:	89 87 14 02 00 00    	mov    %eax,0x214(%edi)
     4d0:	8b 47 20             	mov    0x20(%edi),%eax
     4d3:	8b 48 74             	mov    0x74(%eax),%ecx
     4d6:	83 e9 70             	sub    $0x70,%ecx
     4d9:	8d 0c 0f             	lea    (%edi,%ecx,1),%ecx
     4dc:	89 8f 1c 02 00 00    	mov    %ecx,0x21c(%edi)
     4e2:	0f b6 41 46          	movzbl 0x46(%ecx),%eax
     4e6:	66 c7 41 3c ff ff    	movw   $0xffff,0x3c(%ecx)
     4ec:	66 c7 41 3e ff ff    	movw   $0xffff,0x3e(%ecx)
     4f2:	83 e0 e7             	and    $0xffffffe7,%eax
     4f5:	83 c8 09             	or     $0x9,%eax
     4f8:	88 41 46             	mov    %al,0x46(%ecx)
     4fb:	0f b6 15 00 00 00 00 	movzbl 0x0,%edx
			4fe: R_386_32	sysctl_ipv6_bindv6only
     502:	83 e0 df             	and    $0xffffffdf,%eax
     505:	83 e2 01             	and    $0x1,%edx
     508:	c1 e2 05             	shl    $0x5,%edx
     50b:	09 d0                	or     %edx,%eax
     50d:	88 41 46             	mov    %al,0x46(%ecx)
     510:	80 8f 3f 02 00 00 10 	orb    $0x10,0x23f(%edi)
     517:	66 c7 87 30 02 00 00 	movw   $0xffff,0x230(%edi)
     51e:	ff ff 
     520:	c6 87 3d 02 00 00 01 	movb   $0x1,0x23d(%edi)
     527:	c7 87 40 02 00 00 00 	movl   $0x0,0x240(%edi)
     52e:	00 00 00 
     531:	c7 87 48 02 00 00 00 	movl   $0x0,0x248(%edi)
     538:	00 00 00 
     53b:	a1 04 00 00 00       	mov    0x4,%eax
			53c: R_386_32	ipv4_config
     540:	85 c0                	test   %eax,%eax
     542:	0f b7 87 2a 02 00 00 	movzwl 0x22a(%edi),%eax
     549:	0f 94 87 3e 02 00 00 	sete   0x23e(%edi)
     550:	66 85 c0             	test   %ax,%ax
     553:	0f 85 a3 00 00 00    	jne    5fc <inet6_create+0x30c>
     559:	8b 47 20             	mov    0x20(%edi),%eax
     55c:	31 ed                	xor    %ebp,%ebp
     55e:	8b 50 14             	mov    0x14(%eax),%edx
     561:	85 d2                	test   %edx,%edx
     563:	0f 84 a0 fd ff ff    	je     309 <inet6_create+0x19>
     569:	89 f8                	mov    %edi,%eax
     56b:	ff d2                	call   *%edx
     56d:	85 c0                	test   %eax,%eax
     56f:	89 c5                	mov    %eax,%ebp
     571:	0f 84 92 fd ff ff    	je     309 <inet6_create+0x19>
     577:	89 f8                	mov    %edi,%eax
     579:	e8 fc ff ff ff       	call   57a <inet6_create+0x28a>
			57a: R_386_PC32	sk_common_release
     57e:	66 90                	xchg   %ax,%ax
     580:	e9 84 fd ff ff       	jmp    309 <inet6_create+0x19>
     585:	b8 00 00 00 00       	mov    $0x0,%eax
			586: R_386_32	rcu_lock_map
     58a:	b9 85 05 00 00       	mov    $0x585,%ecx
			58b: R_386_32	.text
     58f:	ba 01 00 00 00       	mov    $0x1,%edx
     594:	e8 fc ff ff ff       	call   595 <inet6_create+0x2a5>
			595: R_386_PC32	lock_release
     599:	83 c4 20             	add    $0x20,%esp
     59c:	89 e8                	mov    %ebp,%eax
     59e:	5b                   	pop    %ebx
     59f:	5e                   	pop    %esi
     5a0:	5f                   	pop    %edi
     5a1:	5d                   	pop    %ebp
     5a2:	c3                   	ret    
     5a3:	e8 fc ff ff ff       	call   5a4 <inet6_create+0x2b4>
			5a4: R_386_PC32	build_ehash_secret
     5a8:	e9 80 fd ff ff       	jmp    32d <inet6_create+0x3d>
     5ad:	bd a3 ff ff ff       	mov    $0xffffffa3,%ebp
     5b2:	83 7c 24 18 02       	cmpl   $0x2,0x18(%esp)
     5b7:	74 cc                	je     585 <inet6_create+0x295>
     5b9:	b9 b9 05 00 00       	mov    $0x5b9,%ecx
			5ba: R_386_32	.text
     5be:	ba 01 00 00 00       	mov    $0x1,%edx
     5c3:	b8 00 00 00 00       	mov    $0x0,%eax
			5c4: R_386_32	rcu_lock_map
     5c8:	e8 fc ff ff ff       	call   5c9 <inet6_create+0x2d9>
			5c9: R_386_PC32	lock_release
     5cd:	ff 44 24 18          	incl   0x18(%esp)
     5d1:	83 7c 24 18 01       	cmpl   $0x1,0x18(%esp)
     5d6:	74 5d                	je     635 <inet6_create+0x345>
     5d8:	89 74 24 08          	mov    %esi,0x8(%esp)
     5dc:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
     5e3:	00 
     5e4:	c7 04 24 1b 00 00 00 	movl   $0x1b,(%esp)
			5e7: R_386_32	.rodata.str1.1
     5eb:	e8 fc ff ff ff       	call   5ec <inet6_create+0x2fc>
			5ec: R_386_PC32	request_module
     5f0:	e9 40 fd ff ff       	jmp    335 <inet6_create+0x45>
     5f5:	89 ce                	mov    %ecx,%esi
     5f7:	e9 d7 fd ff ff       	jmp    3d3 <inet6_create+0xe3>
     5fc:	8b 57 20             	mov    0x20(%edi),%edx
     5ff:	66 c1 c0 08          	rol    $0x8,%ax
     603:	66 89 87 38 02 00 00 	mov    %ax,0x238(%edi)
     60a:	89 f8                	mov    %edi,%eax
     60c:	ff 52 44             	call   *0x44(%edx)
     60f:	e9 45 ff ff ff       	jmp    559 <inet6_create+0x269>
     614:	81 fe ff 00 00 00    	cmp    $0xff,%esi
     61a:	66 89 b7 2a 02 00 00 	mov    %si,0x22a(%edi)
     621:	0f 85 89 fe ff ff    	jne    4b0 <inet6_create+0x1c0>
     627:	83 ca 08             	or     $0x8,%edx
     62a:	88 97 3f 02 00 00    	mov    %dl,0x23f(%edi)
     630:	e9 7b fe ff ff       	jmp    4b0 <inet6_create+0x1c0>
     635:	8b 54 24 10          	mov    0x10(%esp),%edx
     639:	0f bf 42 3c          	movswl 0x3c(%edx),%eax
     63d:	89 74 24 08          	mov    %esi,0x8(%esp)
     641:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
     648:	00 
     649:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
			64c: R_386_32	.rodata.str1.1
     650:	89 44 24 0c          	mov    %eax,0xc(%esp)
     654:	e8 fc ff ff ff       	call   655 <inet6_create+0x365>
			655: R_386_PC32	request_module
     659:	e9 d7 fc ff ff       	jmp    335 <inet6_create+0x45>
     65e:	c7 44 24 0c a2 00 00 	movl   $0xa2,0xc(%esp)
     665:	00 
     666:	c7 44 24 08 a0 00 00 	movl   $0xa0,0x8(%esp)
     66d:	00 
			66a: R_386_32	.rodata.str1.4
     66e:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
     675:	00 
			672: R_386_32	.rodata.str1.1
     676:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
			679: R_386_32	.rodata.str1.4
     67d:	e8 fc ff ff ff       	call   67e <inet6_create+0x38e>
			67e: R_386_PC32	printk
     682:	e9 a1 fd ff ff       	jmp    428 <inet6_create+0x138>
     687:	89 f6                	mov    %esi,%esi
     689:	8d bc 27 00 00 00 00 	lea    0x0(%edi),%edi

00000690 <inet6_destroy_sock>:
