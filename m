From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v5 4/8] thunderbolt: Communication with the ICM
 (firmware)
Date: Sun, 31 Jul 2016 10:18:29 +0000
Message-ID: <E607265CB020454880711A6F96C05A03971086A9@hasmsx108.ger.corp.intel.com>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
 <1469693721-5641-5-git-send-email-amir.jer.levy@intel.com>
 <20160729140224.137dbaac@xeon-e3> <20160729214838.GA14827@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>
To: Greg KH <gregkh@linuxfoundation.org>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20160729214838.GA14827@kroah.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 30 2016, 12:48 AM, Greg KH wrote:
> On Fri, Jul 29, 2016 at 02:02:24PM -0700, Stephen Hemminger wrote:
> > On Thu, 28 Jul 2016 11:15:17 +0300
> > Amir Levy <amir.jer.levy@intel.com> wrote:
> >
> > > +static LIST_HEAD(controllers_list); static
> > > +DECLARE_RWSEM(controllers_list_rwsem);
> >
> > Why use a semaphore when simple spinlock or mutex would be better?
> 
> And never use a RW semaphore unless you can benchmark the difference
> from a normal lock.  If you can't benchmark it, then don't use it...

I used RW semaphore since most of the time the list will be accessed for read.
Since it is used in non-time sensitive flows, I'll change it to mutex.
