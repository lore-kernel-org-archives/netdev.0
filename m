From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] net: fix an array index overflow
Date: Thu, 03 Dec 2009 16:30:34 +0800
Message-ID: <4B17772A.80605@redhat.com>
References: <20091201082901.4678.16688.sendpatchset@localhost.localdomain> <20091202132427.GE5224@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <error27@gmail.com>,
	Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753403AbZLCI1g@vger.kernel.org>
In-Reply-To: <20091202132427.GE5224@bicker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Carpenter wrote:
> On Tue, Dec 01, 2009 at 03:26:02AM -0500, Amerigo Wang wrote:
>> Don't use the address of an out-of-boundary element.
>>
>> Maybe this is not harmful at runtime, but it is still
>> good to improve it.
>>
>> Signed-off-by: WANG Cong <amwang@redhat.com>
>> Cc: David S. Miller <davem@davemloft.net>
>>
> 
> It may be coincidence but my static checker smatch also complains 
> about the code you modified.
> 
> It's the wrong idea to fix code to please a checker.  You end up
> doing things like adding an extra "return -ENOTREACHED" to silence
> warnings.  Then the next person who writes a checker has to figure
> out how to seperate the unreachable code which was added to suppress
> gcc warnings from bits which are unreachable because of typos.
> 
> Really any code that a human can read, a static checker should also
> be able to read.  Computer programs are just state machines.  At 
> the function level they are quite small state machines.  It's all
> logic and math which computers are very good at.  So it should be 
> fairly easy to fix the checker.  ;)
> 

Well, in some cases smatch seems really wrong, but not in this
case I think, or at least, smatch is suggesting us to improve
this code.

Please check Eric's reply in this thread, his patch looks nice
for me.

Thanks.
