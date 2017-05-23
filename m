From: Kees Cook <keescook@chromium.org>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Mon, 22 May 2017 21:27:57 -0700
Message-ID: <CAGXu5j+Pqs-cPfRSm143DTrcj0NH5gmVRMSousgswR75y4R0MQ@mail.gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
 <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
 <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com>
 <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com>
 <591A07A1.1030006@iogearbox.net> <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
 <5922E11C.4070307@iogearbox.net> <CAHgaXd+dTEKyPbkB6oFpLa3z0ygkxK1dMT8R55iYjvsU=GO3Wg@mail.gmail.com>
 <CAGXu5jLYunVCJGCfHPebKDaoQ71hdMGq4HhdDxTYpBQw_HXUYQ@mail.gmail.com> <CAHgaXd+5h7aMxF83EEkD3iRyeZ1JxAX2oFYJdy3GtcNOWRsBGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Daniel Borkmann <daniel@iogearbox.net>, David Miller <davem@davemloft.net>,
	Mircea Gherzan <mgherzan@gmail.com>, Network Development <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, ast@fb.com
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <kernel-hardening-return-7990-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: keescook@google.com
In-Reply-To: <CAHgaXd+5h7aMxF83EEkD3iRyeZ1JxAX2oFYJdy3GtcNOWRsBGw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 7:58 PM, Shubham Bansal
<illusionist.neo@gmail.com> wrote:
> On testing the eBPF JIT with CONFIG_FRAME_POINTER I got the following
> crash for non jitted testcase.

It's just a softlockup WARN, not a crash, and I think it'd to be
expected given the large runtime test_bpf reports:

> [   72.032494] test_bpf: #267 BPF_MAXINSNS: Call heavy transformations
> jited:0 1112799
> [   92.304815] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s!
> [insmod:104]
> ...
> [   93.835343] 1065840 PASS

https://www.kernel.org/doc/Documentation/lockup-watchdogs.txt

You can raise the softlockup time-out by changing the number of
seconds here: /proc/sys/kernel/watchdog_thresh I think the softlockup
is counting the entire runtime of the bpf_tests run, so if it takes 30
seconds to run, put at least 15 into /proc/sys/kernel/watchdog_thresh

-Kees

-- 
Kees Cook
Pixel Security
