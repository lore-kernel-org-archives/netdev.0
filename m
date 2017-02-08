From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH net-next v3 04/11] bpf: Use bpf_load_program() from the
 library
Date: Wed, 8 Feb 2017 17:46:57 -0200
Message-ID: <20170208194657.GC2162@redhat.com>
References: <20170207214500.27496-1-mic@digikod.net>
 <20170207214500.27496-5-mic@digikod.net>
 <589A5597.7090107@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <589A5597.7090107@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Feb 07, 2017 at 03:17:43PM -0800, Alexei Starovoitov escreveu:
> On 2/7/17 1:44 PM, Mickaël Salaün wrote:
> >-	union bpf_attr attr;
> >+	union bpf_attr attr = {};
> >
> >-	bzero(&attr, sizeof(attr));
> 
> I think somebody mentioned that there are compilers out there
> that don't do it correctly, hence it was done with explicit bzero.
> Arnaldo, Wang, do you remember the details?

https://www.spinics.net/lists/netdev/msg411144.html

But this was when some named initializers are used in a union with
unnamed members like 'union bpf_attr', unsure if this would break with
the above case where no named initializers are being used.

Having that said, the above is gratuitous, the code that is being
replaced is not related to the patch at hand, and conceptually the end
result should be the same.

So, please, just leave it as is, i.e. using bzero() and make your patch
a bit smaller, remember, small is good, smaller is even better ;-)

- Arnaldo
