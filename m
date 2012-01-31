From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Tue, 31 Jan 2012 12:55:41 -0800
Message-ID: <1328043341.8702.3.camel@joe2Laptop>
References: <1327963304-24828-1-git-send-email-asharma@fb.com>
	 <CAErSpo54KRJbWEQ0fB_kuGx0qRQKWpH9d3mN=dPdiNfWH+Dhww@mail.gmail.com>
	 <20120131181554.GA24397@dev3310.snc6.facebook.com>
	 <1328035857.6911.8.camel@joe2Laptop>
	 <20120131194718.GA9834@dev3310.snc6.facebook.com>
	 <1328040546.8012.6.camel@joe2Laptop> <4F285310.5060104@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	Ingo Molnar <mingo@elte.hu>, christoph.paasch@uclouvain.be
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F285310.5060104@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-01-31 at 12:46 -0800, Arun Sharma wrote:
> On 1/31/12 12:09 PM, Joe Perches wrote:
> >> +	too_many_orphans = tcp_too_many_orphans(sk, shift);
> >> +	out_of_socket_memory = tcp_out_of_memory(sk);
> >> +	tcp_log_oom(too_many_orphans, out_of_socket_memory);
> >> +	if (too_many_orphans || out_of_socket_memory) {
> > Perhaps these repeated three lines should be a routine like:
> > bool tcp_check_oom(struct sock *sk, int shift)
> > {
> > 	bool tcp_orphans = tcp_too_many_orphans(sk, shift);
> > 	bool tcp_oom = tcp_out_of_memory(sk);
> >
> > 	printks...
> >
> > 	return tcp_orphans || tcp_oom;
> > }
> I like your previous suggestion better. It preserves the ability to write:
> if (too_many_orphans) {
>    do_something();
> }
> if (out_of_socket_memory) {
>    do_something_else();
> }

shrug. That isn't currently used and 
tcp_too_many_orphans and tcp_out_of_memory
could still be checked.

I think the routine could be moved out-of-line.
