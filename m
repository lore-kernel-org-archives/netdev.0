From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Tue, 28 Apr 2009 15:05:09 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904281501300.13862@qirst.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org, Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:56839 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbZD1TPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 15:15:08 -0400
In-Reply-To: <49F71B63.8010503@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the udpping test load these patches have barely any effect:

git2p1 is the first version of the patch
git2p2 is the second version (this one)

Same CPU
Kernel			Test 1	Test 2	Test 3	Test 4	Average
2.6.22			83.03	82.9	82.89	82.92	82.935
2.6.23			83.35	82.81	82.83	82.86	82.9625
2.6.24			82.66	82.56	82.64	82.73	82.6475
2.6.25			84.28	84.29	84.37	84.3	84.31
2.6.26			84.72	84.38	84.41	84.68	84.5475
2.6.27			84.56	84.44	84.41	84.58	84.4975
2.6.28			84.7	84.43	84.47	84.48	84.52
2.6.29			84.91	84.67	84.69	84.75	84.755
2.6.30-rc2		84.94	84.72	84.69	84.93	84.82
2.6.30-rc3		84.88	84.7	84.73	84.89	84.8
2.6.30-rc3-git2p1	84.89	84.77	84.79	84.85	84.825
2.6.30-rc3-git2p2	84.91	84.79	84.78	84.8	84.82

Same Core
Kernel			Test 1	Test 2	Test 3	Test 4	Average
2.6.22			84.6	84.71	84.52	84.53	84.59
2.6.23			84.59	84.5	84.33	84.34	84.44
2.6.24			84.28	84.3	84.38	84.28	84.31
2.6.25			86.12	85.8	86.2	86.04	86.04
2.6.26			86.61	86.46	86.49	86.7	86.565
2.6.27			87	87.01	87	86.95	86.99
2.6.28			86.53	86.44	86.26	86.24	86.3675
2.6.29			85.88	85.94	86.1	85.69	85.9025
2.6.30-rc2		86.03	85.93	85.99	86.06	86.0025
2.6.30-rc3		85.73	85.88	85.67	85.94	85.805
2.6.30-rc3-git2p1	86.11	85.8	86.03	85.92	85.965
2.6.30-rc3-git2p2	86.04	85.96	85.89	86.04	85.9825

Same Socket
Kernel			Test 1	Test 2	Test 3	Test 4	Average
2.6.22			90.08	89.72	90	89.9	89.925
2.6.23			89.72	90.1	89.99	89.86	89.9175
2.6.24			89.18	89.28	89.25	89.22	89.2325
2.6.25			90.83	90.78	90.87	90.61	90.7725
2.6.26			90.51	91.25	91.8	91.69	91.3125
2.6.27			91.98	91.93	91.97	91.91	91.9475
2.6.28			91.72	91.7	91.84	91.75	91.7525
2.6.29			89.85	89.85	90.14	89.9	89.935
2.6.30-rc2		90.78	90.8	90.87	90.73	90.795
2.6.30-rc3		90.84	90.94	91.05	90.84	90.9175
2.6.30-rc3-git2p1	90.87	90.95	90.86	90.92	90.9
2.6.30-rc3-git2p2	91.09	91.01	90.97	91.06	91.0325

Different Socket
Kernel			Test 1	Test 2	Test 3	Test 4	Average
2.6.22			91.64	91.65	91.61	91.68	91.645
2.6.23			91.9	91.84	91.92	91.83	91.873
2.6.24			91.33	91.24	91.42	91.38	91.343
2.6.25			92.39	92.04	92.3	92.23	92.240
2.6.26			90.64	90.57	90.6	90.08	90.473
2.6.27			91.14	91.26	90.9	91.09	91.098
2.6.28			92.3	91.92	92.3	92.23	92.188
2.6.29			90.57	89.83	89.9	90.41	90.178
2.6.30-rc2		90.59	90.97	90.27	91.69	90.880
2.6.30-rc3		92.08	91.32	91.21	92.06	91.668
2.6.30-rc3-git2p1	91.46	91.38	91.92	91.03	91.448
2.6.30-rc3-git2p2	91.39	90.47	90.03	90.62	90.628

