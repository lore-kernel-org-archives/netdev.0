From: Stefan Rompf <stefan@loplof.de>
Subject: dhcpclient netlink bugs (was Re: [NETLINK]: Schedule removal of old  macros exported to userspace)
Date: Tue, 12 Dec 2006 07:56:30 +0100 (MET)
Message-ID: <200612120757.24880.stefan@loplof.de>
References: <20061208.164345.71119524.davem@davemloft.net>  <200612101109.34149.stefan@loplof.de>  <20061210121505.GQ8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, libc-alpha@sourceware.org
Return-path: <libc-alpha-return-19661-glibc-alpha=m.gmane.org@sourceware.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061210121505.GQ8693@postel.suug.ch>
Content-Disposition: inline
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 10. Dezember 2006 13:15 schrieb Thomas Graf:

> > Please send me the list of bugs you've spotted. Of course I want to fix
> > them.
>
> Sure...
>
> static void nl_handlemsg(struct nlmsghdr *msg, unsigned int len) {
>   if (len < sizeof(*msg)) return;
>
>   while(NLMSG_OK(msg,len)) {
>     if (nlcb_run &&
> 	nlcb_pid == msg->nlmsg_pid &&
> 	nlcb_seq == msg->nlmsg_seq) {
>       nlcb_function(msg, nlcb_args);
>
> Missing check for sufficient payload, family specific header
> and attributes are accessed directly, you've only made sure
> a netlink message header is present so far.

Yes, the code has quite some trust into the kernel that if it answers the 
asked question the answer is semantically correct. But to be fair, if you 
issue a write(), you also expect the number of bytes written in return and 
not the msec taken ;-) Will fix that and the other stuff you pointed out, 
thanks!

Stefan
