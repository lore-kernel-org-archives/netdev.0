From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 3/3] Security: Document disablenetwork. (v4)
Date: Sun, 27 Dec 2009 10:39:28 +0900
Message-ID: <200912271039.DHG51586.FMFFHOJSLVQtOO@I-love.SAKURA.ne.jp>
References: <20091227010441.GA12077@heat>
	<20091227010708.GA12216@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: michael@laptop.org, linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091227010708.GA12216@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote
> sendmsg(fd, (struct sockadr *) &addr, sizeof(addr));
I meant
sendto(fd, buffer, len, 0, (struct sockadr *) &addr, sizeof(addr));

Michael Stone wrote:
> +Exceptions are made for
> +  * processes calling sendmsg() on a previously connected socket
> +      (i.e. one with msg.msg_name == NULL && msg.msg_namelen == 0) or

What should we do for non connection oriented protocols (e.g. UDP)
but destination is already configured by previous connect() request?

struct sockaddr_in addr = { ... };
int fd2 = socket(PF_INET, SOCK_DGRAM, 0);
connect(fd2, (struct sockadr *) &addr, sizeof(addr));
prctl( ... );
sendto(fd2, buffer, len, 0, NULL, 0); /* Should we allow this? */
sendto(fd2, buffer, len, 0, (struct sockadr *) &addr, sizeof(addr)); /* Should we reject this? */
