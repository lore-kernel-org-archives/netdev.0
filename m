From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple calls
 in eBPF
Date: Fri, 27 Jun 2014 12:19:00 +0200
Message-ID: <53AD4514.9040708@redhat.com>
References: <1398882591-30422-1-git-send-email-chema@google.com> <1401389758-13252-1-git-send-email-chema@google.com> <5387C8AD.6000909@redhat.com> <CA+ZOOTNobzzJPgQnVVZ+b6rRD=0_pdjUB8q5FQVkbO+dob0BSg@mail.gmail.com> <538C6FD8.9040305@redhat.com> <CAMEtUuyduk1sHBeVm=d5GYEgB4ma7sVFYeBLdapbeEpQY9nA1Q@mail.gmail.com> <538D884E.5030007@redhat.com> <CAMEtUuxK5hV_eORRLaSHSiwF5X82Ae91vL6W0-6au48v8H6bAA@mail.gmail.com> <CA+ZOOTPdDDeGxZVGXVRZmjkxqkGefgDLrawo_9YXbjwTQ_FLzA@mail.gmail.com> <538EDE1A.8060305@redhat.com> <CA+ZOOTONwNt2xpwUc=tqhP=m31KZTzij-rrAHVh6g3hVYgKaEw@mail.gmail.com> <53A9337F.50707@redhat.com> <CA+ZOOTNSW-SFaX8zbBqoz8nGtkqBshcagTHt6HMLokczV6xZ6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Chema Gonzalez <chema@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ZOOTNSW-SFaX8zbBqoz8nGtkqBshcagTHt6HMLokczV6xZ6g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/26/2014 12:00 AM, Chema Gonzalez wrote:
...
> There's still the problem of whether we want to obsolete classic BPF
> in the kernel before the tools (libpcap mainly) accept eBPF. This can
> take a lot.
>
> Finally, what's the user's CLI interface you have in mind? Right now,
> tcpdump expressions are very handy: I know I can pass "ip[2:2] ==
> 1500" or "(tcp[13] & 0x03)" to any libpcap-based application. This is
> very handy to log into a machine, and quickly run tcpdump to get the
> packets I'm interested on. What would be the model for using C-- eBPF
> filters in the same manner?

Yes, imho, it's a valid question to ask. I think there are a couple
of possibilities for libpcap/tcpdump from a user point of view (note,
I don't strictly think it's the _only_ main user though): 1) iff a
llvm and/or gcc backend gets merged from the compiler side, one could
add a cli interface to run the generated opcodes from a file for
advanced filters while perhaps classic BPF continues to be supported
via its high-level filter expressions; 2) there could be a Linux-only
compiler in libpcap that translates and makes use of full eBPF (though
significantly more effort to implement); 3) libpcap continues to use
classic BPF as it's currently doing.
