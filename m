From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 17:33:17 -0800
Message-ID: <4F3DAE5D.3080000@zytor.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>    <1329422549-16407-3-git-send-email-wad@chromium.org>    <4F3D61CB.2000301@zytor.com>    <CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>    <4F3D7250.6040504@zytor.com> <501858544d264abc6526f2b25a224f2b.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <501858544d264abc6526f2b25a224f2b.squirrel@webmail.greenhost.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/16/2012 04:48 PM, Indan Zupancic wrote:
> On Thu, February 16, 2012 22:17, H. Peter Anvin wrote:
> 
> I would go for something like:
> 
> struct seccomp_data {
> 	int nr;
> 	__u32 arg_low[6];
> 	__u32 arg_high[6];
> 	__u32 instruction_pointer_low;
> 	__u32 instruction_pointer_high;
> 	__u32 __reserved[3];
> };
> 

Uh, that is the absolutely WORST way to do it - not only are you
creating two fields, they're not even adjacent.

> (Not sure what use the IP is because that doesn't tell anything about how
> the system call instruction was reached.)
> 
> The only way to avoid splitting args is to add 64-bit support to BPF.
> That is probably the best way forwards, but would require breaking the
> BPF ABI by either adding a 64-bit version directly or adding extra
> instructions.

Or the compiler or whatever generates the BPF code just is going to have
to generate two instructions -- just like we always have to handle
[u]int64_t on 32-bit platforms.  There is no difference here.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
