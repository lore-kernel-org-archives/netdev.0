From: David Miller <davem@davemloft.net>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Sun, 19 Apr 2009 00:44:24 -0700 (PDT)
Message-ID: <20090419.004424.141669610.davem@davemloft.net>
References: <200904182123.HFF13509.MVSJtQHFLFOFOO@I-love.SAKURA.ne.jp>
	<20090418.212842.163717535.davem@davemloft.net>
	<200904191412.GIF95380.SVFJOHOFOQtLMF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904191412.GIF95380.SVFJOHOFOQtLMF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 19 Apr 2009 14:12:15 +0900

> David Miller wrote:
>> We worked so hard to split out this common code, it is simply
>> a non-starter for anyone to start putting protocol specific test
>> into here, or even worse to move this code back to being locally
>> copied into every protocol implementation.
> You don't want LSM modules to perform protocol specific test inside
> __skb_recv_datagram(). I see.
> 
>> You may want to think about how you can achieve your goals by putting
>> these unpleasant hooks into some other location.
> May I insert security_socket_post_recv_datagram() into the caller of
> skb_recv_datagram() (as shown below)?

This definitely looks better, yes.
