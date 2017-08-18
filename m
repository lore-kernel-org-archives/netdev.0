From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Thoughts on staging and on fixing up drivers?
Date: Thu, 17 Aug 2017 20:22:37 -0500
Message-ID: <20fc6365-bd3d-011b-e688-71ac97197911@lwfinger.net>
References: <20170817174652.17656-1-Larry.Finger@lwfinger.net>
 <20170817204531.dorcib3omnxi3f6u@mwanda>
 <CAP8WD_aSE7f31Y9HNJ0h_6CNocB0Yjm_qeDjk=wnBJV16T=F7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, PJ Waskiewicz <pjwaskiewicz@gmail.com>,
 Ping-Ke Shih <pkshih@realtek.com>, Yan-Hsuan Chuang <yhchuang@realtek.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Shaofu <shaofu@realtek.com>,
 Birming Chiu <birming@realtek.com>, netdev <netdev@vger.kernel.org>,
 Steven Ting <steventing@realtek.com>
To: whiteheadm@acm.org, Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAP8WD_aSE7f31Y9HNJ0h_6CNocB0Yjm_qeDjk=wnBJV16T=F7A@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 08/17/2017 04:07 PM, tedheadster wrote:
>>
>> Larry, you've migrated a bunch of staging code, and tried various
>> approaches.  Do you have any lessons on what has worked and what hasn't
>> and if there is anything we can do to make the process better?
> 
> I am also quite interested in such work. We asked for a Birds of
> Feather discussion at the upcoming Linux Plumbers conference on
> exactly this sort of work.

Matthew and Dan,

I will try to answer the question as best I can.

I got started in working with Realtek wireless devices at roughly the time that 
staging was created. At that time, Realtek published drivers sporadically. They 
would accumulate fixes in their internal svn repositories, then take a snapshot, 
and publish that with no information regarding what was changed. Even trying to 
diff the two versions was not useful. Obviously this mode of code development is 
not consistent with the Linux model.

After I was able to get driver r8712u into staging, I received an E-mail from 
Realtek asking if I would be willing to help them get their drivers into the 
kernel. They have provided sample chips and extenders to let me test drivers on 
my laptops, but I have not gotten any remuneration from Realtek. This 
collaboration has led to the rtlwifi family of drivers. A few of them have gone 
through staging because there was some urgency in getting them added to Linux. 
That is the case for today's submission of a driver for the RTL8822BE, which is 
appearing in some computers. This particular device implements a new Realtek 
model for hardware abstraction of the MAC, PHY, and dynamic management 
functions, which has increased the number of new lines of code to about 120K. 
Getting that much new code through the review process in the wireless tree would 
take a lot of time. Essentially, staging allows users to have access to the 
functionality while that review is in progress. Another card now appearing in 
the wild is the RTL8723DE. It will likely also reside initially in staging.

Besides getting wifi drivers for these cards into Linux, I have also been 
training the Realtek engineers and getting them to issue fixes as many small 
changes. That part of my "job" has been going very well, and I will soon be 
getting them to submit their material directly. That change is necessary as I am 
now 77, with the question of how long I will be continuing.

As you can tell, I am very pleased with the staging tree and its usage for new 
drivers, particularly where the regular trees move more slowly than the 
marketplace. Staging is a big help in supporting the users that otherwise will 
have no wifi under Linux. Their distro may not build staging drivers in their 
standard kernels, but configuring and building kernels is not too difficult.

The part that does not work is best exemplified by the driver that got me 
started, namely r8712u. The USB section at Realtek has not been as cooperative 
as the PCI/SDIO group. As a result, there is no path from staging to wireless 
and that driver will be left in staging as long as GregKH allows it. Now, I put 
that sort of material in a GitHub repo and force users to build it as an 
out-of-kernel driver. Of course, that method has its own problems. How many 
times a week do you want to tell another user that they need to install the 
kernel-headers, and no, I do not know how to do it on your distro. Now we have 
one example (rtl8723bs) where the GitHub driver was placed in staging. That one 
is likely to be moved to wireless.

This reply is getting rather long. I will be happy to answer any further questions.

Larry
