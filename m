From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Regression in virtio_net causing kernel BUG when running under
 VirtualBox (bisected)
Date: Mon, 29 Mar 2010 11:12:21 -0700
Message-ID: <1269886341.13277.6.camel@localhost.localdomain>
References: <4BAE1707.2050803@mathtm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas =?ISO-8859-1?Q?M=FCller?= <thomas@mathtm.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BAE1707.2050803@mathtm.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Thomas,

Good catch! The problem was sg_init_table was missing for small buffer
size. When CONFIG_DEBUG_SG is off, you won't hit this, but your test has
DEBUG_SG on so SG_MAGIC check failed. You can turn DEBUG_SG off to avoid
this.

I thought you should hit the same problem before since I didn't remember
sg_init_table was used for small message size.

I will submit a patch for fix this issue soon.

Thanks
Shirley
