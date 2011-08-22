From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [omega-g1:11072] Re: [PATCH] net: configurable sysctl parameter  =?UTF-8?Q?=22net=2Ecore=2Etcp=5Flowat=22=20for=20sk=5Fstream=5Fmin=5Fwspa?=  =?UTF-8?Q?ce=28=29?=
Date: Mon, 22 Aug 2011 16:21:59 +0200
Message-ID: <1ee3ee6e05ae30a229306a8863c83d44@localhost>
References: <4E48B0C3.2010203@ctc-g.co.jp>
 <20110814.224714.2061635645365376268.davem@davemloft.net>
 <4E4E2CCD.6050809@ctc-g.co.jp>
 <20110819.024326.598275465899000817.davem@davemloft.net>
 <4E51A3F0.5010500@ctc-g.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<omega-g1@ctc-g.co.jp>, <notsuki@redhat.com>,
	<motokazu.kozaki@hp.com>, <htaira@redhat.com>,
	<netdev@vger.kernel.org>, <tomohiko.takahashi@ctc-g.co.jp>,
	<kotaro.sakai@ctc-g.co.jp>, <ken.sugawara@ctc-g.co.jp>
To: <jun.kondo@ctc-g.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E51A3F0.5010500@ctc-g.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 22 Aug 2011 09:33:52 +0900, "Jun.Kondo" wrote:

> By using this patch, we want to prevent "timeout occured over the

network

> that is low throughput but available".

> 

> But in the current implementation, both blocking and non-blocking,

> user processes can't recognize the reason in detail

> when failed to write to socket buffer, we think.



For your application it should not matter WHY the data can be written to

the peer. It can be happened that the peer close the window, some

scheduling bottleneck or whatever else. A blocking socket means for you

that some data is in the pipe, waiting for transmit. This is the knowledge

that you require, and you should deal with it. A blocking socket does not

mean FAILED, a failure is returned via ECONNRESET or otherwise. So

everything is fine when your socket blocks. Probably you should adjust your

Apache timeouts or other parts of the program logic.



> As stated above, we think it is difficult for user processes to handle

> timeout of writing socket buffer,

> when wmem is configured large value.(to ensure high throughput over the

> high ralency network, like 3G).



No, you should adjust your code and account that the socket has data in

the pipe. That's all.



Changing tcp_lowat
