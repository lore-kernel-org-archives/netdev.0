From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] n_gsm: Add Mutex to avoid race when net destroy
Date: Fri, 01 Mar 2013 10:10:17 +0100
Message-ID: <51307079.2050905@suse.cz>
References: <1362029486.31563.5.camel@bichao>  <512F28FD.9030502@suse.cz> <1362127915.31563.18.camel@bichao>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
	vincentx.pillet@intel.com
To: channing <chao.bi@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362127915.31563.18.camel@bichao>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/01/2013 09:51 AM, channing wrote:
>> It should stop the queue and schedule a workqueue to lock the mutex,
>> unregister the hetdev and reset dlci->net. (Or maybe just call
>> muxnet_put with the lock held.)
> 
> Thanks, Jiri, you're right, I didn't notice that in validation because
> DEBUG_ATOMIC_SLEEP is not enabled in my platform :( Now I'm trying to
> work out the workqueue solution, when it finished I'll re-submit for
> review. What do you mean by "call muxnet_put with lock held"? do you
> mean to use spin lock instead of mutex?

No, I mean, in the newly added scheduled work, to lock the mutex and
simply call muxnet_put. That should fix it, right?

-- 
js
suse labs
