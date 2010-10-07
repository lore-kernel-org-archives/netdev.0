From: =?UTF-8?B?Q2h1bmctWWloIFdhbmcgKOeOi+W0h+aHvyk=?=
	<cywang@google.com>
Subject: Re: [PATCH] net: Fix sk_dst_check() to reset the obsolete dst_entry
 of a socket.
Date: Thu, 7 Oct 2010 12:37:32 -0700
Message-ID: <AANLkTikz8=H9=O2RR9J0=rHm7pcwabnMupKfiSfGnt1k@mail.gmail.com>
References: <AANLkTikkv4htP1f=KFwSaa8=K6LicDN0eusXctow-Efb@mail.gmail.com>
 <20101006.003541.71128466.davem@davemloft.net> <AANLkTikx+GadeYfg5rZNxsEig-0Af97ER7V94fjaVc+U@mail.gmail.com>
 <AANLkTimF7piLEy7BUP4-BnmiiGT4NimZw0gE+kmYQd-c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimF7piLEy7BUP4-BnmiiGT4NimZw0gE+kmYQd-c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As I am testing the l2tp/ipsec client(it is working fine on 2.6.32 but
failed on 2.6.35 with the same client). Please see the following log
dump for sk_dst_check().

<2>[  201.390289] ==== sk_dst_check sk=C7485800 dst=C717AC60
obsolete=FFFFFFFF cookie=0 check=C0296510
<2>[  211.247467] ==== sk_dst_check sk=C7485000 dst=C717AC60
obsolete=FFFFFFFF cookie=0 check=C0296510

[Basically, the ipsec tunnel is built and then free the dst_entry for
this l2tp socket. Therefore, the obsolete entry should be reset in
sk_dst_check(). However, the kernel 2.6.35 will do nothing here since
the ipv4_dst_check still return the obsolete entry even if it is
obsolete(dst->obsolete=2)]

<2>[  216.571350] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<6>[  218.069396] alg: No test for authenc(hmac(sha1),cbc(des3_ede))
(authenc(hmac(sha1-generic),cbc(des3_ede-generic)))
<6>[  218.164764] batt:  96%, 4114 mV, 0 mA (-6 avg), 27.2 C, 1305 mAh
<2>[  218.575561] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  220.580535] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  222.585754] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  224.591522] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  226.599212] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  228.602600] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  230.608062] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  232.613464] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  234.618896] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  236.623504] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  238.628936] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  240.634338] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  242.639709] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  244.645111] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  246.648864] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  248.654693] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  250.660125] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
<2>[  252.665527] ==== sk_dst_check sk=C7485400 dst=C6F670E0
obsolete=00000002 cookie=0 check=C0296510
