From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v1 7/7] bpf: Always test unprivileged programs
Date: Mon, 6 Feb 2017 08:09:04 -0800
Message-ID: <58989FA0.7000906@fb.com>
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-7-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
        "Shuah Khan" <shuah@kernel.org>,
        Arnaldo Carvalho de Melo <acme@infradead.org>
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170205231428.23846-7-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/5/17 3:14 PM, Mickaël Salaün wrote:
> -		if (unpriv && test->prog_type)
> -			continue;
> +		if (!test->prog_type) {
> +			if (!unpriv)
> +				set_admin(false);
> +			printf("#%d/u %s ", i, test->descr);
> +			do_test_single(test, true, &passes, &errors);
> +			if (!unpriv)
> +				set_admin(true);
> +		}
>
> -		printf("#%d %s ", i, test->descr);
> -		do_test_single(test, unpriv, &passes, &errors);
> +		if (!unpriv) {
> +			printf("#%d/p %s ", i, test->descr);
> +			do_test_single(test, false, &passes, &errors);
> +		}

great idea.
Acked-by: Alexei Starovoitov <ast@kernel.org>

as far as other patches.. we need to figure out how to avoid conflicts
between net-next and Arnaldo's tree where Joe's patches went.

Mickael,
can you see some way of splitting the patch set between trees?
Like above test_verfier.c improvement needs to go into net-next.
The rest can go via perf
