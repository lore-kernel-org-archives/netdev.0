From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 21/29] ioat2,3: dynamically resize descriptor ring
Date: Tue, 15 Sep 2009 16:07:05 -0700
Message-ID: <e9c3a7c20909151607h5171784ence5e6722adab4ad7@mail.gmail.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
	 <20090904023216.32667.55942.stgit@dwillia2-linux.ch.intel.com>
	 <129600E5E5FB004392DDC3FB599660D7B5548192@irsmsx504.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <129600E5E5FB004392DDC3FB599660D7B5548192@irsmsx504.ger.corp.intel.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 14, 2009 at 8:00 AM, Sosnowski, Maciej
<maciej.sosnowski@intel.com> wrote:
> Making the max_alloc_order a module parameter gives impression
> that it can be modified by an user, including making it larger than default.
> The default is however its maximum value, which may be confusing.
> Why not to use parameter only as the upper limit?

It is the upper limit.

The user can limit the upper size of the descriptor ring by setting
this to a value less than 16.  By default it is the maximum ring size
that the driver/hardware* supports.  Specifying values greater than 16
are not supported by the so we need enforce a ceiling at 16.

--
Dan

* We could support ring sizes larger than 1 << 16 but we would need to
extra logic to ensure that the pending count never exceeded 1 << 16.
Simpler I think to just limit the maximum ring size.
