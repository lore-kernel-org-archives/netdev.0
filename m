From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v3] arm: eBPF JIT compiler
Date: Sat, 19 Aug 2017 19:11:51 -0700
Message-ID: <b63fae4b-cb74-1928-b210-80914f3c8995@fb.com>
References: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com>
 <c2f4c796-0cb0-7eca-6cab-fed6b25020d5@fb.com>
 <CAHgaXdJnHxu4gJ8ZVFmrmaXyZL1oFkTbz2K___xKLQedTLmBQg@mail.gmail.com>
 <9d77730f-c6a8-b337-599e-5919207a7e0a@fb.com>
 <CAHgaXd+hccuUYXfTs6gMbvxBctrypofc2FJ10q3QAc0jGsgeyQ@mail.gmail.com>
 <CAHgaXdJDOseZk0=4uCGeCx44kgnvHf1gnh7CX2c6dTzXb8Rk+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Network Development <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAHgaXdJDOseZk0=4uCGeCx44kgnvHf1gnh7CX2c6dTzXb8Rk+g@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 8/19/17 2:46 PM, Shubham Bansal wrote:
> test_pkt_access:PASS:ipv4 271 nsec
> test_pkt_access:PASS:ipv6 297 nsec
> test_xdp:PASS:ipv4 961517 nsec     <--- Here is the difference.
> test_xdp:PASS:ipv6 615855 nsec     <--- Here is the difference.

yes. this is expected. These two numbers are single run
on cold cache, so there will be run-to-run variation.

> test_l4lb:PASS:ipv4 3049 nsec
> test_l4lb:PASS:ipv6 3906 nsec

These two and the first two were the ones I was interested in,
since they do many iterations over the same set and
the best to compare code gen changes.
The delta % is actually better than I expected judging by test_bpf
micro-benchmarks, so the results are very encouraging.

Thanks!
