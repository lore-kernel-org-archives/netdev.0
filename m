From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] sk98lin: Driver update v7.09
Date: Fri, 29 Oct 2004 09:26:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029092603.0aab72de@zqx3.pdx.osdl.net>
References: <417907C1.6050407@syskonnect.de>
	<20041027102519.0fc3c7a9@guest-251-240.pdx.osdl.net>
	<4182812D.8020407@syskonnect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, rroesler@syskonnect.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlindner@syskonnect.de>
In-Reply-To: <4182812D.8020407@syskonnect.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 19:43:09 +0200
Mirko Lindner <mlindner@syskonnect.de> wrote:

> Stephen,
> 
> thank You for the help! Should we help you in any case to check or 
> change the defines?
> 
> We have the problem that the Linux driver consists of multiple files 
> which are also used for other drivers running on other OSes
> (e.g. Sun, HP-UX, MacOS X, *BSD, Windows, PXE, AIX, Unixware...).
> 
> This is for instance the reason why we must use redefines for the
> different data types (e.g. SK_U32). Can you please explain what you mean 
> with "UglyReDefineTheWorld"? Are there any special defines you do not 
> like? I am wondering why the style plays such an important role when 
> looking at the driver source. I am not sure what redefines you are 
> referring to, but the datatype redefines for example have been in the 
> kernel tree for years without any complains.

Style matters especially things like:

#define SK_NET_DEVICE	net_device
#define SK_IOC			char __iomem *

because it means that source code inspection tools like cscope will
not easily pickup all usages of the structure when developers need to
do audit's to change interfaces.

My goal is to make all the linux only pieces look as close to linux style
as possible without going to the extreme of changing variable names and
function names.

The common parts will not be touched at all. My plan will be to make
one of the patch steps up these in one chunk.


> If you could send us a list about the requested changes you'd like to 
> perform, we can help you or provide additional support. We would really 
> appreciate it, if you could inform us in advance about those changes,
> because the driver was tested extensively in our test&verification 
> department and by a considerably amount of OEM vendors. Changing now 
> parts of the code may break the driver functionality or the 
> functionality of the driver files used on other OSes.
> 
> Cheers
>   Mirko

So far I have about 10 patches done, and most of the way through getting ethtool
working using your code. EMany ethtool functions needed minor work to resolve
issues like not checking parameters and error handling.
