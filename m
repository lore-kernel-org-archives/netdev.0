From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next] route: fib_validate_source remove the <=
 RT_SCOPE_HOST test
Date: Wed, 14 Oct 2015 01:17:33 +0800
Message-ID: <201510140125.S1Zd1vHc%fengguang.wu@intel.com>
References: <a9569cddcdeb5f0b7d138a22086f76f1b9e5acd5.1444754404.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Content-Transfer-Encoding: 8bit
Cc: kbuild-all@01.org, network dev <netdev@vger.kernel.org>,
	davem@davemloft.net, fw@strlen.de
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57523 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753099AbbJMRST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 13:18:19 -0400
Content-Disposition: inline
In-Reply-To: <a9569cddcdeb5f0b7d138a22086f76f1b9e5acd5.1444754404.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Xin,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Xin-Long/route-fib_validate_source-remove-the-RT_SCOPE_HOST-test/20151014-004206
config: cris-etrax-100lx_v2_defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=cris 

All warnings (new ones prefixed by >>):

   net/ipv4/fib_frontend.c: In function '__fib_validate_source':
>> net/ipv4/fib_frontend.c:328:6: warning: unused variable 'ret' [-Wunused-variable]

vim +/ret +328 net/ipv4/fib_frontend.c

a207a4b2 David S. Miller 2012-06-28  312  
a207a4b2 David S. Miller 2012-06-28  313  	return inet_select_addr(dev, ip_hdr(skb)->saddr, scope);
35ebf65e David S. Miller 2012-06-28  314  }
35ebf65e David S. Miller 2012-06-28  315  
^1da177e Linus Torvalds  2005-04-16  316  /* Given (packet source, input interface) and optional (dst, oif, tos):
6a31d2a9 Eric Dumazet    2010-10-04  317   * - (main) check, that source is valid i.e. not broadcast or our local
6a31d2a9 Eric Dumazet    2010-10-04  318   *   address.
6a31d2a9 Eric Dumazet    2010-10-04  319   * - figure out what "logical" interface this packet arrived
6a31d2a9 Eric Dumazet    2010-10-04  320   *   and calculate "specific destination" address.
6a31d2a9 Eric Dumazet    2010-10-04  321   * - check, that packet arrived from expected physical interface.
ebc0ffae Eric Dumazet    2010-10-05  322   * called with rcu_read_lock()
^1da177e Linus Torvalds  2005-04-16  323   */
7a9bc9b8 David S. Miller 2012-06-29  324  static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
7a9bc9b8 David S. Miller 2012-06-29  325  				 u8 tos, int oif, struct net_device *dev,
7a9bc9b8 David S. Miller 2012-06-29  326  				 int rpf, struct in_device *idev, u32 *itag)
^1da177e Linus Torvalds  2005-04-16  327  {
1dced6a8 Sébastien Barré 2014-08-17 @328  	int ret, no_addr;
^1da177e Linus Torvalds  2005-04-16  329  	struct fib_result res;
9e56e380 David S. Miller 2012-06-28  330  	struct flowi4 fl4;
5b707aaa Denis V. Lunev  2008-01-21  331  	struct net *net;
9e56e380 David S. Miller 2012-06-28  332  	bool dev_match;
^1da177e Linus Torvalds  2005-04-16  333  
9ade2286 David S. Miller 2011-03-12  334  	fl4.flowi4_oif = 0;
385add90 David Ahern     2015-09-29  335  	fl4.flowi4_iif = l3mdev_master_ifindex_rcu(dev);
cd2fbe1b David Ahern     2015-08-13  336  	if (!fl4.flowi4_iif)

:::::: The code at line 328 was first introduced by commit
:::::: 1dced6a854827eb5683f3c57ddbb4595daf145e4 ipv4: Restore accept_local behaviour in fib_validate_source()

:::::: TO: Sébastien Barré <sebastien.barre@uclouvain.be>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--MGYHOYXEY6WxJCY8
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICD07HVYAAy5jb25maWcAjDxbc9s2s+/fr+CkZ85830May7c454weQBCUUPEWAJTkvHAU
WW40dSQfSW6bf392QVK8LZR2pq2NXSxue9+lf/nXLx57O+2/r07b9erl5Yf3+2a3OaxOmyfv
efuy+V8vSL0kNZ4IpPkVkKPt7u3vD+vD9ujd/nrz69X7w/rGm20Ou82Lx/e75+3vbzB7u9/9
65d/8TQJ5aSI43z8o/7lS5qIIohZM6IWWsTFRCRCSV7oTCZRymcA/8WrMJji02LKdCGjdHJd
5DfXHiy/25+84+bkRru/baNVSPU604WQk6lptlEDOIukr5iBXYqIPTYISVrINEuVKWKWNcNh
qriAoaU9WqoCocb3NVAbxmdGMcDQeYaTm4lcSd38Nv0yHl1dnddSBc9yPR7VA4EIq58iqc34
3YeX7dcP3/dPby+b44f/yhMWi0KJSDAtPvy6tu/wrp4r1edikSq8UniUX7yJfeEXvJW31+aZ
fJXORFKkSaHj1vlkIk0hkjlcLy4eSzO+uW7OkGpd8DTOZCTG7941j1GNFUZoQzwDPDGL5kJp
mSY4jxguWG7SZh9wAyyPTDFNtcHjjt/9e7ffbf7TWlMvWEZyhn7Uc5lxEpalWi6L+HMuckFs
tDxhLOJUPRbMwHtO26wZTlkSRNTEXAtgpA4b5yBDbUz7GvA63vHt6/HH8bT53rxGzY74eHqa
LpqLsGwO1DXgGCNjkYahFhQnx6ku8iwAXq6fHpjqg1kd//BO2+8bb7V78o6n1enordbr/dvu
tN393uzASD5DLiwY52meGJlM2qfxdVBkKuUCrgcwDHm5hukZyIDRg2Mrnnt6eGxY5bEAWHsl
+LUQy0woipF0D9muiFPI/SAp2E8UIX/GaUJvWglhMa3gOungluBBReGnKX16P5dRUPgyuaZZ
T87KH0j5wOkhPL0MzXh02xKsiUrzTJME+VTwWZbKxIAy0CZV9O5RfHQGZ6OpaCATWOmzS7kk
KtQgk5kSHPgroG8JFSh9M9EMJs+tclH0ZM6LNAP2ll8E6thCww/U+z9qbqKWdCSgOWSSBqKt
XNlcFLkMRvfNmJ+FzS8lezW/93BjUDwSRE41QxqELwZesxsAhmpB7NU0w+07g63WEPLQMwDo
x1gTB80UPOustf980tp/FAJHK9ECgyUowry9sTA3Ytmak6WdbctJwqIwaEZQt6j2gJiLxNiB
5iGzkDpQTXMKirP1NrKlz1kwl7DFarJuE8Wbtso+DAiiQNJnSkn7Guc5MCiCoMuIVtFUvkm2
OTzvD99Xu/XGE39udqD0GKg/jmpvczg2Gmgel+csrNIDU9S6oij3gW07N492jhkwnh2PRUfM
p+4DCHTRUt8lXgacIlDdrABzKEMJUiYd+gq0cCgjUM8kNAew75B0Kxf3tz5YePB6JgmKPUeN
Tuzdmp0Fg4sBS1pkTMHj1Qb8R0dsrdMDqxrBQQVRL5gGeQT2C97Zci7qieZGs4lhPngOETwD
8EXja0ToOvpAe8FUoK+bGSloWWBfnetMJMFgnHFTbrL0fng6f/91dQQH94+SNV4Pe3B1S9s3
dCYRv7piUbjk1l5kbXfBuwW2mAoFXEQyAQOTELZEAV1KlM22yrLyq2NUIVfNOtXNEVT9ymmu
7YcfsLAjqJXG9TXNJi04uC0/UdpGTJQ0btXO4wD4UZRcogYima0Opy3GCJ758bo5tq8dZhhp
rPcXzFnCBakBdACezRm1paBC2RkuHazU0+tvG3SV23Iu09LOJWmatS+qHg8Es4cg1q9RePh5
6J+Wg2dy9TAuQ5CqwRXJ8bv18/81jntibxFDoiK3URG6g23X3MIV7LSCX4KRcxcKPRjH5Daw
mt04vuAkfSHe1hVcAMfHBqW9rToVBFl5nJ1vAZXBFHbc0brVVA3xUmbaW7BCx9Lc4XyV02Kp
OXHvuDYu3eId8PaWNeeO3x32+9P4w9Pmzw/fT09fX/brP2687W4LYy8YAR/WrbijnLpghk+D
lPLmSoSQaVMa1Y7hsrAZSjo408EFEQdfS8QZslIi2hTq8XkagcViipbLCougG0bMdOw0DhTo
QqGtraLd7q2jy4sw1GMWk9oumwigNNHgXRnQy6KlmXUWgc3JjOUsG+nedgwq78p1LCeKmZ6l
yaaPEHkEgSpMacOIPdTZBjzSpImmfTDtvOUszSWoYJOCT9XxQ2Y6viCyMVwM7CyxexjfXn06
R/2JgHcEh9JGT7O4Yx4hRE84BJG0Z/4lS1Pawnzxc9pP/qJL1qEjDIhN7UPYWGbW8xGswE5X
h6e/VofNWWK7nDm6uoqWLpa2wGJ+PeDn0BGfKAmxNJwezKvJBL9xyoo1v/PR1VBSSkg3BdRB
CBSLbbTQylNUAhgxPcVHXsjATMcUdFTOvO2var2+AhM4V+TJ+lijf4RF57H6WO5banCKpHT1
y/eDa/b+HF15+1e0si2j17oh5PmcRdbRGK+vyn+6eBkDJyzQwzfIfAu4sHuus6uf4STpAKMD
B+Bo0n8lHFTjm8Hg9aRRIc2gGt8NBm8omjeqPwgBNM/B+ApFMGEDvPTQDdalh26wLj00eMlg
YaTBbAr4iZ/uVvcUCjB3UQ6PR1cDLtb48j9ZxDJHTWJ1DUxxe+XEw/g8mYzv7kcjCsdyJnBR
INV4tL6IAZHOuM9/bRS/3tNlJFzpJxi40vPz4GrSEHyMaW6CdJEQV5S0M2zwC5i+CbycrmUu
2Zz+2h/+gChiKHVgz2ai47qUI7BbRrkLeSKXnXgYfnfhLkPVMTD4uw2gSY6zUA1RLMT+ktOO
gsUpLS5tpEoiwIdSG8lpCccbmolHYsMy6V6FzMr0CmeaduQAoY4FCgXenuNogJYldLLKPlcm
LwEn6IqKOF9ewClMniSCNs/6MQEGTWfSEWmXFOZGOqF5cHEBRAlTOquJV1qwqRsmNH12WW4L
XS433D73hZ1ZpCF8QCJGhxJkLdHdOkgfw1Jygn3RYx8ERyp1LY1i0yNmeFYPd8ngE/TFrMkK
wyz4cXIpMD3j8NyXfBgb1nAI896+btshBELi4E5LenFgnXsXW2BpB6wHj5maOVknM7AyODha
hrTU14TAq7YxCsh3nPX8xQY1lJHphjHnwdIpuTTtfINnf2UP7ico0Ofty2lzcJURm/mN6iWW
h58ggpu5axJD1EHt5wJulNIvlGACNkmsm+1CsHktp36oFlpewAIdpIVTS86HVRaZ/c+Fi23v
DVhUMctot67tB3l2EY41C6YcWrYEX5quxG+CGzcKnBCwZHb5fgAF9nAZJ+Dcoe/gfrmhYcrh
yxpXYRGCanI8unas4CsZTKhI2obcVplp1mb6ecSS4uHqevSZpBcInji4JYo47ZLKjLaA4DRF
NF8vr+/oJVhGpxGzaeralhRC4HnuHEwiTFmcoo/LHWlLeAhm84kkOM1EMoeI0HDagM51ir6a
U2ytVsBcwEUEp1mJs8iRm9e0n2MvwW43EPSJrEW8gThbl+p4TrAU4qglhguPRbcO5H+Oej6t
d9ocT730uLUpMzMRdEliymLFApmSQM7oSVIFjH5BmlsY6Iylyqj03kJiM0TXRPBwgrxFB2yR
9AfA8rz1rN1m83T0Tnvv68bb7FZfX7BDZn/wYsYtQqvfpRpBHxlLCFPbHWLzCq1U/kLCKK1p
wpl01Bnw2j/RnMaZDGmAyKaFK6efhLTyihZDj87eR3DY/rk5HO3Rv76BXXm/3XlbrKE9r9ab
QapBmKlQndipCreEkiwaBtbleCtVeiFwrnGjHK7YJvkY2WvSwQamtz0TubENDnp85yD7s1xP
C+1SDqCFdikJ0EK7uYCm9O0DrW5LeK592yDjvIXSMqK7aFI1vr+7u7nv05COboUSOskcUl2d
4zHhU5Umaa6rM7lTfEupbc6tl2CukkOVPxpB1JcmxWIqkgI1qZMcNQHzyHNpHmuFFmz+3K43
NQ/DUFOy2K6rYS/th+95WQ+eiihrdwB0hiGiN9NOAxToXRNnIZXeAr2QBCwq0/i1VVQluVCq
eMEgGrXNI62c/AIcKKyMtIZqVJlArK06UZNYwqWcMTobO1OyaYJ6/yGLIr/nu9Z6NorSha38
taomrXNiDjJQcu4Q1gpBzJWr3+RRF9NH2MRc6pSmcW5pynKkJF2tK6gF9BROHGD3TEjUp/y3
o/dk2aBTd0Tf3VmuNp2WB/gVfNUASyC22EjvBLFaZdALWEx9HGLYveVHYMe4bPKz3QrmsNod
X6z77kWrH516JpLyoxncTqt2Vg722ilD4zAuLoB0QlQYOMlpHQa0JtGxcxJuOE0d7U0IPJd3
sVRmPZzBtSkWf1Bp/CF8WR2/eetv21fv6Szx7ecJZfemfhPgMtt2ie44cF9RD3cfOJToV9pG
pTShRB2xsE7kM3ACbdmhGHWJ96DXF6G3/R304A/Oe+tvgk4nEJhkpaU+vOwdxo5dU9ckaZf+
DHbv3IITA/7ckrJr53eIAz0UVISAumUXJuZGRt1TAAMNBD6lgzkrwL7udXpYNoxXr6+YDn5q
eUyWGVdrUD59XkwhEBBLvHzMuuj++ljsdMUYlkXBLNtCpFtwImZ62f8OPMLy9YCEPYnevDy/
X+93p9V2B14vYFcqtCVXHVo6urRSNqWrEJb5TFDefjNm6wwpxJ+1C90FCWU7ZRB0f9uDwctg
f+/46u+r7hasTrzGgwz82+3xj/fp7j3Hlxr4Cx0iQcontLOG0ARsvFvFJaIPt9SjDO//v8v/
X3sZj73vm+/7ww/XTZcTXMvoTBaJw6QiPPfpfHRKRxKge9FBJZ6uag2iGo6wMIm/0JFdhcTB
wbjQkVujRb0mmgFCoHz60s+78am8bQ3tsF5rsOwFHI/uKVhZMMbyf+NNBKAvMD7mwZzeDzb2
peAxYYB0ccPTy+fpnbdUPNvjmvJxwHOLH7GPh/bfEx6lOle2Eun2sLRLsvl1nzfs2kJkqDuP
b6+v+8Op015gIcWnG768H0wzm79XR0/ujqfD23fbrXn8tjqA8jmhC4SkvBdQRt4TnHX7ij+2
SRtU+gOaDJOgKy/MJsx73h6+266Hp/1fu5f96skrP6aoYwIJEe2LF0tuHcZSAdQwzSHSHg43
U6b748kJ5KvDE0XwPNRcEJ86EijLsmzvBJbRQMEyWrwRRYgpIQg20yiDjqMju9091Y61rG1A
87Q1iwAQizWdHn4mA/x8QrlazjW9VUsLvHo3sMqwuaSM1n2UEgBCVWjRbjxquYiYfKmarBs5
TJPA1Xlr5Y2Wtc85i+QXR8Bka1TCZUAZx7QvnapcuiBAEn7SaeQsc2AS0LkbBGKIZBT84Ni1
yR1fU+RJMbdXZ7+kcexg7tKDSdQzCqWEYLKrUQVP3YAebPjpsP36hh+x6b+2p/U3jx3A9Tpt
1qe3A+m1VNn1Ip4/PIj75dJdB+5gVa1eWU7wUyv11TAklnhYYTSV5kfqc5EEqcImpx7fQcBe
tqy1OYHqMW9R8RXE+WBWOwx7SzviPo8xyKYzrUEPMFxKfOFTmXX3XIGs705DHq7vlksSFDM1
F93PJ+J53MsoE9MkV6Iza6YfHu5GRUx+n9CamTB4lFiSm3m4+dTrAZqmVNa5NQUFHB0akp6C
i9ZM0zCsNigSpFms8+5HWHo58UXfhyBmCvGZJmnwxtIOSRMDZ/0Dmo8JxOmP9CnmkpHjC/ml
JxHlSLG4G13R2dYzwo0DAUIjV3Y7yxxfL0XdZpCyERKs9vvj9mnj5dqvrZrF2myeqmQ/Quqq
CHtavWJVdWD/FqCFOx2zKUSg9EYWURGLQDIjaAMG8G7LSOlT2fKDt9hiBeHfw86j/2CZ4rjZ
eKdvNRah8hauMowOhgpX7l7fTkOL30oRZfnQ4zr3lsoPqYdTWlEvZoe7jIcD+N++H9nDgMfO
NJ1LLxEUW1yAVir4MgmAYlPSJTKKO2lMWCxIZ5iDD7taI9M07nltJm2WurGHlL7FPrBPD0Vm
Hjv5AfBaMqPLLqoswnQwJpg52UMeiQnjjzWJwWAV6Fzf3XfPC8F3kiZl3trxvV5STDTtslTf
P9PJe9h8p/ccfp+VA1Xq4bBdvVDsW20LTMjV4J6T/e69BRzL6VaSCa6taORMgQ/p6HarcDTn
ydKhTUqMirF+M2yCBP8B6k/RlCN/WhW+dATxv5MIcFT10SAt5lksi/LrZSrpPV2AHIHO7jgP
58GyNidTeCk6L2zonWMm1QVTN5+6X+yX3wrxmEvmrQnJaQUXi0sFCMPh3ywe6rRrTqoyR/1L
O6IpDRdJAqZ6qLqzTFNrZtkw+49j1R9j2B+OrVkl1GTeGj9LIcmZrBjdPTzgN3Pdkk7bflSG
E78Cd3Z/tQzJ6unJfrQF8mQXPv7aaC/blK8grJFK2Fxk+el7/erUQFURGpaSnBVGO8t+XTtM
eZRJsu+r11ew1JYCoTLKZReuxhQLritNmC4NU0Wzd7kTPr0ZjZbDvYRBuYPN369wt32rSxeL
s3QhlP0bEZHj8x2LwOaUUp8u4u6nMXYAnDBaU5fQ8rLRax+qz9UJ7o5WuhBEKl2EH0cPV3d0
lrCN83Ad0rFxjWRvMnR4IjWSNA8fLyKAhzP6dBkl4w8fb+5pD7KNc3t9mU5ieIGBXSy1cWRW
z6jc3N8/0BniNs7Hj3RJv8bRUzP6CUas+e3HmGatLpJ/85OLAra+g9D2Ujq2Rp2bkaufpkZZ
PNzcX3+cXuaUEkk4sOxtMzo5ceGbO62xy11r6UfnP3+h97vt+ujp7ct2vd95/mr9x+vLqps7
hHlUhpjHbEDOP+xXT+v9d+/4ullvn7drj8U+axPDaUMF8fZy2j6/7da2jnuhkhIGNt9EC7HB
j7C15I4KBMydiTiLHDWIEEst9y5eQLCO767ot2X+8u7qyr01O/tRcwf3INhgve7m5m5ZGM2Z
o0xsETN9f/dpRPvZFiF2WAslJjnocFf1A6Ou+m/yDF5ocli9fkNOIWxroIaeRHhYfd94X9+e
n8FBCYYOSujqTOSzCP8KURHxgNpMEw5MmP3whxYj8NmphCY2A6VTLiFiMgbiAgjBJWt9VYnw
wV8lwsHzt+9T3kni5l3RKHsUYIzKweF49u3HEf+qVNmrQLE4rgY+Bx1QpJmFL7mQdKMjQq0B
mfs5nVe2GCyYOPJa+YJ+mDh2cKSI8ZMXV5v9wv3FW/lnFaQvI9d38+AWlx36dAYuZpf6Xli+
DKTOXH9uJXfIiP3utfSchz7VfHsABUW9Gk6DW497olcVn9aH/XH/fPKmP143h/dz7/e3zZGO
viBScuXOsYksFmcvbLi7c2pBv2531g/uMSC3g3r/dqC1K37zHBWZpDkjZjLyU+rDVwh64rwl
N50WMgv0stXv/9/YtfW2jSvhv+LHXeBsN3G6RffhPFAX26p1cUgpdvIipI6RGN3Ege1gT//9
4QwpiZJm6AIFUnOGF5HD4ZCc+bg7o4mt+ka71Gbqefd+PGxJ46qMMcYlqyUAK40+Wb6/np6H
n6k0428KUZQmxdsErq1/79Yj4uZaVfkm4a/xdHk1E6W0ysBmn2kznyTHm5JV+QifRW9DGdFc
ren2JRA6V3PzXW8o8JLGe1Mxy8Z9C0rIhaNyd6xmP8BoKdgxrTainn7NM9jxMSBjLpdWSvR6
pq2FelnkAjn4GmEnEHK+IOFYRbvQN6/aAtLbSWo6SjGeZeLt6XjYP/XmTR7JgtlZ5HeDAwGz
Ou71TDA925NELTDTmokU17QbD+0zR5NxAuBBiqN/40kbnjSfKbalQempLk9ST9bZlM8J6FqM
f/hMWdA6EVKXGghUA/t+A9jWZsqLMpk5eIbRMCExCbUFuurqE4ZANua2KphLVqSEjJ8foIvN
FDuMM4AGYmjgNqEXupo4Bggfty8Dy0uNwBYMOfoDXATBPQPEk5DORBV/f/lyxbWiimZUC6JC
/TkT5Z95yZVrwGuYUu90XlaWypG0mOl92n08HRCts6uu0RV6HdF5XDdjnbDsQ4Vh2hBHDRMR
OULvAhNwFu8hjmhiuEjSSMZUsDT4H7i14qFN9xP9ot3yMIEW6gHPBnwI6A1Rpa28NMA20yYF
/hn1YTMsiQpx6hjorV7zRMTPUzHjaQsvaZVWLDmI+awBTxrnatWeUUPdGDQpFs/sapSO4D/G
idrti44O8ISITUYrBsOoqizjEGnaovhBNSzgHAkBnwALxbvaGt6HAeimSU0fqItjQ5Nw4DnO
Iqsgoa2ZtJiTnRxqm6ov1+q2EmrBzXXPgpMlEPLPKcDMI1crnnabbz57qV94qvRVuuKhJgF5
lVWhnLQ2p9H96dgQMVf/99108PumFxuMKaxiQTIXlap4UFlNpHbdc7ztWsHtiBO+Aevx8Keu
td9sc+TmqM0ql6uwJ1CYMg6x7pQcBHtx6DsJt7KEKzZPEQle9fF2TzpepywQ48vj9scgmNCi
HVqQvbH/8ftx/3b+gRcVT6+7k4uw4SxJcNOFlxeUdtfaA9YyPXURVrCJyHeBfkxAhykmGiKX
mqoOr+96lf0DwXO1pbH9ccJGbU36kWqXOWYHnCyiWXGO0VhrIXMHS9WJ4jH0rFKlwXZ17DkJ
kM+Q87/XV1PnM1QpATFDZfUQSNQxkkWEBQvmxrbKtf0Fh3hZUDDhqWgaFOvcG/RDzm4L8NZ+
0CAPhKaBotcLcia4oFzz9Yh0628AgnOvY7Fs8LiY3f48QROo7xvbK6qNsHIvnKLd94/n54E4
Y9cg5pniIDstcJNm5LG7DE8RQFQ84zXZ4pHW3Ek9cIwAmIc9Dnid2urnDCfDdUeLiiFafGyA
8/VVtBg4H9ugPN2Hk/Sw/fHxbubT4vHtuTeJQF1WABM4hhR1qgCiNgNzAwLNSG2uBxrMiEGM
EUWv70RaOQEHhmijR7vkBi7SwMJ2XY/Jw4nfJ/MjY3KbkYnzyEwWT9dCq5ZxPETs6KxnuK8f
S4IJOoCDslaSJ7+d7Ina6T+T14/z7n87/Z/defvp06ffx5qtwy71DbwF9fdJ0MVCRFlkMEtT
/ZkeNrvzBednrUvSGQDQ08Ui+KAWpxKc3oc49Y4+bSD8PZUuzTT1NSthyreqILnEweC2GiJu
0JOY8a62V70yjuK8TASxNgNeOq3LpN5us3DqysAAAxq6Txdf7GMEW/8lJj8i+63ymEamFzDy
B7QzBujSxovtzDqWEv1Xv5kliV6JDHwrxWN6FmD1tblQjjEU4Etx1GvF3fsE3fMRgI3K902A
oPUs3cydL5/bGUGPEzRoEW8gxJdnAAMjn9u4YQYTBfiWmrEs6CMsZJCAjYDx6IQmNtj5UREq
2bOAMWcT18yXXY0suE5oBYTa+YAJl/OIvheyky1L+BjVHFwY5xbuCdwE8hFwt3Vs234c9+ef
lM24jO+ZVSEOKwBeriNt0OJptx4LRu00vF4iaaA1aFVdbYLAsmqozusdobxf4ZMd5mOOP9/P
B20cH3eTw3HysvvnHeNbesy1SOdaU3fF95Kn43RtPJKJY9YgXYbJahHLMQkEj0wcs0r3ELVL
IxnbXcWQhghrxMc4Dex2XLY4RcWsWmImcm2syVGBNp0qbwgJSGaso0ThxgAXTaKU+ex6+jWr
qGNny5H3nhxwEsefD3t8hN4iKsI/zMMQtsmXWURVLuJ8fNkjPs4vuzd48AgiROK3LUgq+GL8
uz+/TMTpdNjukRQ9nh/didk0LmRC4Gwn+cnhQuh/06tVkd5f31zRnj2WV8W3CQXfY8mxLkjb
3HetQwreeb4engbgBrbigN5oNGTmDK4lc5i+tim0yrTkVNI+2e0E8bdtQ5itC4juZ781EyTs
t53qmQgJodtcaMXdoFAbbPSsl3aqCTK8YVxJXY4LDOX1VcQB+1hxA8Xl7dxfELQsok/AWrI/
d6IFMU7hr49NZpFWH5c4GCe9jmP6Fw1e0HHcTL1lqIW45oVDU3UNhHhowl+MJ5LlKOfy+m8v
x3o1KMIIzv79pQdP0S5slBIWeRUk3skoZOgdTm0Er2eJX2pCkcVpmtB3ey2PKr2CAQzewYoY
Q8ySZ/jXx7FciAfhXQWU3vAIv0A0KtmvihncuZYuVwMYiJF4xN7eLNfFcFDaY8fj7nQagDa2
PQhw/cyVl2F54OKjGuX8wMQZG/LXz16RTh+8sqbJC8KX5fHt6fA6yT9ev++O9tGIISplK+4q
qcOVJLFIm06QARxC5dXIyEAKo+8N7YL2RKbB2jjmGNX7LSlLfAFGFqt7xh7DM4pL9beMylqL
v8QsOb+qAR+Yzp51ct0a87vjGTyKtFlkkExO++e3R4ymxYPwwdY20NseacNPZqPBT/ffj4/H
n5Pj4UPvid0oqCApAQdLqp5NaB76AKfEjk40unHVQSjfMkmdS6LWiydMwIHLfb+xfWiPS+4P
XqitPz20TOeGDK4O5POu5LqisqqpoC80EgZtuJmSG/k+Q5qEcXD/lchqKNysRRYh17xSAY6A
OenVVNqnWOsgr0UU0oYBPppoBt8+tWVHhj4Hwegkf/eANoRz2dS8i+imWl3qdtnmAXBUycoM
qQ7Cb0Qt+A5p0Qttg6Tey6fRrRsXncIt+FgAm6ObjtK657anOtCMZIYOFGVy199PFTJiOotD
jlH2fRZ6PJrKFThpiv4V+f8BM51vyE52AAA=

--MGYHOYXEY6WxJCY8--
