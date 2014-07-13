From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH net-next] net: ppp: don't call sk_chk_filter twice
Date: Sun, 13 Jul 2014 09:03:23 +0200
Message-ID: <20140713090323.14624salobzn3nzv@berry.schulz.ip-v6.eu>
References: <53BF8DEC.4000307@kristov.de>
 <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
 <20140712231126.103531fxfrk9sola@kristov.noip.me>
 <CAADnVQKdTb6B_LsSogr94RS=FwL2Wngc8ACCWavSgaiMqxqdQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <CAADnVQKdTb6B_LsSogr94RS=FwL2Wngc8ACCWavSgaiMqxqdQg@mail.gmail.com>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Alexei Starovoitov schrieb am Sun, 13 Jul 2014 03:44:59 +0200:

> I think this patch still makes sense for 'net-next' as cleanup. Just  
> explain it
> correctly in the log. It's not needed for 'net'.

OK.

> As far as stable for 3.15, I'm not yet sure what exactly the problem
> you're hitting. The way you describe it, the whole ppp filtering shouldn't
> be working in 3.15...

I'm afraid this is true. The pppd daemon fails to set the filter(s)  
with the message "Couldn't set pass-filter in kernel: Invalid  
argument". (It doesn't try to set the active-filter because it gives  
up after the first error.) For 3.15.x, you have to apply both of my  
patches to make it work. For 'net', presumably only the second patch  
("fix creating PPP pass and active filters") is necessary because as  
you wrote, sk_chk_filter() can be called multiple times there. See  
also my comment in our bug tracker where the creation of the filter is  
compared between 3.14.x and 3.15.x (I'm afraid the description is in  
German):

https://ssl.nettworks.org/bugs/browse/FFL-858?focusedCommentId=17289&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-17289

> Also it sounds like you've created a patch out of 3.15 tree, but marked it
> as 'net-next'. That's not the right. If the tag is 'net-next' it obviously
> should be based on net-next tree.

Yes, this was my fault. I'm sorry. I will resubmit the patches soon.


Regards,

Christoph Schulz

