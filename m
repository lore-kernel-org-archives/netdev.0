From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: avoid copying junk bytes in
 bpf_get_current_comm()
Date: Fri, 11 Mar 2016 10:35:10 -0800
Message-ID: <56E30FDE.3050702@fb.com>
References: <1457582553-395600-1-git-send-email-ast@fb.com>
 <56E29CDA.5010004@iogearbox.net> <56E2FE44.7040904@fb.com>
 <56E3083E.6010001@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tobias Waldekranz <tobias@waldekranz.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E3083E.6010001@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/11/16 10:02 AM, Daniel Borkmann wrote:
> Would strscpy() help in this case (see 30035e45753b ("string: provide
> strscpy()"))?

I've looked at it too, but 990486c8af04 scared me a little,
it's not easily backport-able and mainly I don't think
it's faster than strlcpy for small strings like comm.
memcpy going to be faster for sure.
