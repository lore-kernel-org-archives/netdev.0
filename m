From: Hannes Eder <heder@google.com>
Subject: Re: [PATCH] ipvs: Add boundary check on ioctl arguments
Date: Wed, 30 Sep 2009 17:33:01 +0200
Message-ID: <b5ddba180909300833g2b1fd22ak3e094e10fe10e8a@mail.gmail.com>
References: <20090930131109.2b3f71b8@infradead.org> <4AC35F44.60707@google.com>
	 <20090930171833.5ce0011d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754777AbZI3PdK@vger.kernel.org>
In-Reply-To: <20090930171833.5ce0011d@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2009 at 17:18, Arjan van de Ven <arjan@infradead.org> w=
rote:
> On Wed, 30 Sep 2009 15:38:12 +0200
> Hannes Eder <heder@google.com> wrote:
>> =A0> @@ -2353,17 +2357,25 @@ do_ip_vs_get_ctl(struct sock *sk, int c=
md,
>> =A0> void __user
>> *user, int *len)
>> =A0> =A0{
>> =A0> =A0 =A0unsigned char arg[128];
>>
>> can MAX_ARG_LEN be used here?
>
> I am not convinced... it is a different numerical value,
> so it could be an ABI change. Rather not do that in this
> type of patch...

=46or do_ip_vs_set_ctl MAX_ARG_LEN is used:

static int
do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned =
int len)
{
	int ret;
	unsigned char arg[MAX_ARG_LEN];
=2E..

I assume that will be fine for do_ip_vs_get_ctl as well.

-Hannes
